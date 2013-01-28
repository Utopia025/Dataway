namespace :revenue do
	desc 'script to create the conditioned revenue table--uses hoovers, factset, and MI researched revenues'
	task :create_table => :environment do
		current_date = "#{Time.new.year}-#{Time.new.month}-#{Time.new.day}"
		factset_pull_date = '2012-12-06'
		hoov_table = 'scarr.rev_hoov_04052012'
		factset_table = 'scarr.rev_factset'
		
		# create table, and insert baseline Hoovers revenue data
		ActiveRecord::Base.connection.execute("DROP TABLE revenue_table; CREATE TABLE scarr.revenue_table (revenue_id serial, ent_id int4, ult_parent_name VARCHAR, name VARCHAR, factset_name VARCHAR, ticker_symbol VARCHAR(255), revenue FLOAT, updated_by VARCHAR, date_updated DATE, revenue_source VARCHAR, is_verified VARCHAR, year_founded int4); INSERT INTO revenue_table (ent_id, ult_parent_name,\"name\", factset_name, ticker_symbol, revenue, updated_by, date_updated, revenue_source, is_verified, year_founded) SELECT ent_id, ult_parent_name, name, factset_name, ticker_symbol, revenue, updated_by, date_updated, revenue_source, is_verified, year_founded FROM #{hoov_table};")
		puts 'Created revenue table, and inserted Hoovers data'
	


		puts "\nAggregating  FactSet data..."
		# pulling down all tickers from the rev table, looking up the revenue numbers in the FactSet table by those tickers, then inserting the FactSet revenue back into the revenue table	
		tickers = ActiveRecord::Base.connection.execute("SELECT ticker_symbol FROM scarr.revenue_table WHERE ticker_symbol IS NOT NULL;")
		fact_data = []
		tickers.each do |tick_hash|
			record = ActiveRecord::Base.connection.execute("SELECT * FROM #{factset_table}  WHERE ticker_symbol = '#{tick_hash['ticker_symbol']}';").to_a
			if !record.empty?
				record[0]['revenue'] = record[0]['revenue'].to_f
				data_hash = Hash.new
				data_hash[tick_hash['ticker_symbol']] = record[0]
				fact_data << data_hash
			end
		end
		
		puts 'Pulled tickers, now inserting data...'
		
		fact_data.each do |row_hsh|
			ticker = row_hsh.keys[0]
			data_hsh = row_hsh[row_hsh.keys[0]]
			begin
				rev = db_entry (data_hsh['revenue'])
				puts "Inserted: \n\tTicker: #{db_entry ticker}\n\tData: factset_name = #{db_entry data_hsh['factset_name']}, revenue = #{rev}, updated_by = 'FactSet', date_updated = #{db_entry factset_pull_date}, revenue_source = 'FactSet', is_verified = 't'" 
				ActiveRecord::Base.connection.execute("UPDATE scarr.revenue_table SET factset_name = #{db_entry data_hsh['factset_name']}, revenue = #{rev}, updated_by = 'FactSet', date_updated = #{db_entry factset_pull_date}, revenue_source = 'FactSet', is_verified = 't' WHERE ticker_symbol = #{db_entry ticker};")
			rescue => e
				p "~~~Error:\nROW: #{row_ar}\nRevenue: #{row_ar['revenue']}"
				puts "#{e.message}\n"
				next
			end
		end 
		puts 'Overwrote Hoovers revenue for public companies with FactSet'




		puts "\nInserting remaining FactSet data"
		# inserting factset tickers/rows that were not originally in the rev_hoov table
		fact_extra = ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS fact2; SELECT fact.* INTO TEMPORARY fact2 FROM #{factset_table} fact LEFT JOIN #{hoov_table} hoov ON fact.ticker_symbol = hoov.ticker_symbol WHERE hoov.name IS NULL; DROP TABLE IF EXISTS sf_ticks; SELECT ultimate_parent_entity_id__C, ultimate_parent_entity_core_na, entity_id__c, entity_core_name__c, tickersymbol INTO TEMPORARY sf_ticks FROM sf.accountx WHERE tickersymbol IS NOT NULL; SELECT sf.entity_id__c ent_id, sf.ultimate_parent_entity_core_na ult_parent_name, sf.entity_core_name__c \"name\", fact.factset_name, fact.ticker_symbol, fact.revenue,  CAST('FactSet' AS VARCHAR) updated_by,  CAST('#{factset_pull_date}' AS DATE) date_updated, CAST('FactSet' AS VARCHAR) revenue_source, CAST('t' AS VARCHAR) is_verified, CAST(NULL AS int4) year_founded FROM fact2 fact LEFT JOIN sf_ticks sf ON fact.ticker_symbol = sf.tickersymbol WHERE sf.ultimate_parent_entity_id__c IS NOT NULL").to_a
		fact_extra.each do |row_ar|
			ActiveRecord::Base.connection.execute("INSERT INTO scarr.revenue_table (ent_id, ult_parent_name, \"name\", factset_name, ticker_symbol, revenue, updated_by, date_updated, revenue_source, is_verified) VALUES (#{db_entry row_ar['ent_id']}, #{db_entry row_ar['ult_parent_name']}, #{db_entry row_ar['name']}, #{db_entry row_ar['factset_name']}, #{db_entry row_ar['ticker_symbol']}, #{db_entry row_ar['revenue']}, #{db_entry row_ar['updated_by']}, #{db_entry row_ar['date_updated']}, #{db_entry row_ar['revenue_source']},  #{db_entry row_ar['is_verified']})")
		end
		puts 'Added extra FactSet tickers/revenue data'

	end

	# insert string into database
	def db_entry val_or_null
		if val_or_null == 'Null'
			'NULL'
		else
			if val_or_null.class == String
				if val_or_null =~ /'/
					"'#{val_or_null.split(/'/).join("''")}'"
				else
					"'#{val_or_null}'"
				end
			elsif val_or_null.class == Fixnum || val_or_null.class == Float
				val_or_null
			end
		end
	end


	task :test1 => :environment do
		x = 100.222
		puts x.class
		puts db_entry x
	
	end
end
