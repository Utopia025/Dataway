namespace :crunch_dep do
	desc 'these are methods required for the cruchbase scraper script'
	task :crunchmethods => :environment do
		#  normalizes the amount funded (converts to int, appends right amount of 000's)
		def normalize_money x
			val = x.scan(/\d+[.\d+]*[mkb]/i)[0]	
			if val.nil?
				return x.scan(/\d+/).join.to_i
			end
			case val.scan(/[a-zA-Z]/)[0].to_s.downcase
				when 'k'
					if val =~ /\./ 
						sub_val = val.scan(/\d+/)[1]
						t = '000'
						"#{val.scan(/\d+/)[0]}#{sub_val}#{t[sub_val.size, t.size-1]}".to_i
					else
						(val.scan(/\d+/)[0].to_i*1000).to_i
					end
				when 'm'
					if val =~ /\./ 
						sub_val = val.scan(/\d+/)[1]
						t = '000000'
						"#{val.scan(/\d+/)[0]}#{sub_val}#{t[sub_val.size, t.size-1]}".to_i
					else
						(val.scan(/\d+/)[0].to_i*1000000).to_i	
					end
				when 'b'
					if val =~ /\./ 
						sub_val = val.scan(/\d+/)[1]
						t = '000000000'
						"#{val.scan(/\d+/)[0]}#{sub_val}#{t[sub_val.size, t.size-1]}".to_i
					else
						(val.scan(/\d+/)[0].to_i*1000000000).to_i	
					end
			end
		end
		
		# takes a short date (ex: 9/12) and normalizes it to its long entry for DB entry (ex: 9/1/12)
		def normalize_date short
			dates = short.scan(/\d+/)
			if dates.size == 1
				"01-01-#{dates[0]}"
			elsif dates.size == 2
				"#{dates[0]}-01-#{dates[1]}"
			elsif dates.size == 3
				"#{dates[0]}-#{dates[1]}-#{dates[2]}"
			end
		end
		
		# insert string into database
		def db_str_entry val_or_null
			if val_or_null == 'Null' || val_or_null.empty? || val_or_null.nil?
				'NULL'
			else
				if val_or_null =~ /'/
					"'#{val_or_null.split(/'/).join("''")}'"
				else
					"'#{val_or_null}'"
				end
			end
		end

		# insert int into database
		def db_int_entry val_or_null
			if val_or_null.class == String
				if val_or_null == 'Null' || val_or_null.empty? || val_or_null.nil?
					'NULL'
				elsif val_or_null.empty?
					'NULL'
				end
			else
				"#{val_or_null}"
			end
		end
	end
	
	# create fnl tables
	task :create_final_tables => :environment do
		puts 'Creating final tables'
		ActiveRecord::Base.connection.execute("CREATE TABLE scarr.crunch_main_fnl (crunch_ent_id SERIAL, crunch_ent_name VARCHAR, ticker VARCHAR, employees INT4, founded DATE, website VARCHAR, category VARCHAR, products TEXT, description VARCHAR, blurb TEXT);")
		ActiveRecord::Base.connection.execute("CREATE TABLE scarr.crunch_acquisitions_fnl (acquisition_id SERIAL, crunch_ent_id INT8, crunch_ent_name VARCHAR, acquired_crunch_ent_id INT8, acquired_crunch_ent_name VARCHAR, date_acquired DATE, amount INT8)")
		#ActiveRecord::Base.connection.execute("CREATE TABLE scarr.crunch_competitors_fnl (acquisition_id SERIAL, company_id INT8, company_name VARCHAR, acquired_company VARCHAR, date_acquired DATE, amount INT8)")
		ActiveRecord::Base.connection.execute("CREATE TABLE scarr.crunch_funding_fnl (funding_id SERIAL, crunch_ent_id INT8, crunch_ent_name VARCHAR, investing_entity VARCHAR, investing_cohort TEXT, cohort_id INT4, round VARCHAR, cohort_amount INT8, date_invested DATE)")
		ActiveRecord::Base.connection.execute("CREATE TABLE scarr.crunch_investments_fnl (investment_id SERIAL, investing_crunch_ent_id INT8, investing_crunch_ent_name VARCHAR, invested_crunch_ent_id INT8, invested_crunch_ent_name VARCHAR, date_invested DATE)")
		#ActiveRecord::Base.connection.execute("CREATE TABLE scarr.crunch_people_fnl (investment_id SERIAL, investing_company_id INT8, investing_company_name VARCHAR, invested_company_id INT8, invested_company_name VARCHAR, date_invested DATE)  SELECT * FROM scarr.tmp_crunch_people")
		puts 'Created final tables'

	end
	
	# inserts error-free scrape-and-stuff tables into their respective final version tables; need to run this after scraping
	# a portion of the crunchbase company pages --> if scrape is successful this inserts the data in the test tables into the
	# final tables, if error occurs in scrape, DO NOT RUN, go back and fix error, then re-run
	task :final_insert => :environment do
		puts 'Inserting into final tables'
		# main table
		ActiveRecord::Base.connection.execute("INSERT INTO scarr.crunch_main_fnl (crunch_ent_name, ticker, employees, founded, website, category, products, description, blurb) SELECT crunch_ent_name, ticker, employees, founded, website, category, products, description, blurb FROM scarr.tmp_crunch_main")
		# acquisitions table
		ActiveRecord::Base.connection.execute("INSERT INTO scarr.crunch_acquisitions_fnl (crunch_ent_id, crunch_ent_name, acquired_crunch_ent_id, acquired_crunch_ent_name, date_acquired, amount) SELECT scarr.crunch_main_fnl.crunch_ent_id, scarr.tmp_crunch_acquisitions.crunch_ent_name, m2.crunch_ent_id, scarr.tmp_crunch_acquisitions.acquired_crunch_ent_name, scarr.tmp_crunch_acquisitions.date_acquired, scarr.tmp_crunch_acquisitions.amount FROM scarr.crunch_main_fnl RIGHT OUTER JOIN scarr.tmp_crunch_acquisitions ON scarr.crunch_main_fnl.crunch_ent_name = scarr.tmp_crunch_acquisitions.crunch_ent_name LEFT OUTER JOIN scarr.crunch_main_fnl m2 ON m2.crunch_ent_name = scarr.tmp_crunch_acquisitions.acquired_crunch_ent_name")
		# competitors table
		ActiveRecord::Base.connection.execute("INSERT INTO scarr.crunch_competitors_fnl (crunch_ent_id, crunch_ent_name, competitor_crunch_ent_id, competitor_crunch_ent_name) SELECT scarr.crunch_main_fnl.crunch_ent_id, scarr.tmp_crunch_competitors.crunch_ent_name, m2.crunch_ent_id competitor_crunch_ent_id, scarr.tmp_crunch_competitors.competitor FROM scarr.crunch_main_fnl RIGHT OUTER JOIN scarr.tmp_crunch_competitors ON scarr.crunch_main_fnl.crunch_ent_name = scarr.tmp_crunch_competitors.crunch_ent_name LEFT OUTER JOIN scarr.crunch_main_fnl m2 ON m2.crunch_ent_name = scarr.tmp_crunch_competitors.competitor ORDER BY 2")
		# funding table
		ActiveRecord::Base.connection.execute("INSERT INTO scarr.crunch_funding_fnl (crunch_ent_id, crunch_ent_name, investing_entity, investing_cohort, cohort_id, round, cohort_amount, date_invested) SELECT scarr.crunch_main_fnl.crunch_ent_id, scarr.tmp_crunch_funding.* FROM scarr.crunch_main_fnl RIGHT OUTER JOIN scarr.tmp_crunch_funding ON scarr.crunch_main_fnl.crunch_ent_name = scarr.tmp_crunch_funding.crunch_ent_name ORDER BY 2")
		# investments table
		ActiveRecord::Base.connection.execute("INSERT INTO scarr.crunch_investments_fnl (investing_crunch_ent_id, investing_crunch_ent_name, invested_crunch_ent_id, invested_crunch_ent_name, date_invested) SELECT scarr.crunch_main_fnl.crunch_ent_id, scarr.tmp_crunch_investments.crunch_ent_name, m2.crunch_ent_id, scarr.tmp_crunch_investments.invested_crunch_ent_name, scarr.tmp_crunch_investments.date_invested FROM scarr.crunch_main_fnl RIGHT OUTER JOIN scarr.tmp_crunch_investments ON scarr.crunch_main_fnl.crunch_ent_name = scarr.tmp_crunch_investments.crunch_ent_name LEFT OUTER JOIN scarr.crunch_main_fnl m2 ON m2.crunch_ent_name = scarr.tmp_crunch_investments.invested_crunch_ent_name ORDER BY 2")
		# people table
		ActiveRecord::Base.connection.execute("INSERT INTO scarr.crunch_people_fnl (crunch_ent_id, crunch_ent_name, person, title) SELECT scarr.crunch_main_fnl.crunch_ent_id, scarr.tmp_crunch_people.crunch_ent_name, scarr.tmp_crunch_people.person, scarr.tmp_crunch_people.title FROM scarr.crunch_main_fnl RIGHT OUTER JOIN scarr.tmp_crunch_people ON scarr.crunch_main_fnl.crunch_ent_name = scarr.tmp_crunch_people.crunch_ent_name")
		puts 'Inserted into final tables'

	end

	# drop fnl tables
	task :drop_final_tables => :environment do
		puts 'Dropping final tables'
		ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS scarr.crunch_main_fnl")
		ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS scarr.crunch_acquisitions_fnl")
		ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS scarr.crunch_competitors_fnl")
		ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS scarr.crunch_funding_fnl")
		ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS scarr.crunch_investments_fnl")
		ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS scarr.crunch_people_fnl")
		puts 'Dropped final tables'

	end
end

