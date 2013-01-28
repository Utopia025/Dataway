namespace :crunchtest do
       	desc 'this is a scraper script built to pull relevant data from crunchbase'
	task :singlescrape => [:environment,'crunch_dep:crunchmethods']  do
		# next up, gems are already applied, run test to scrape a page, then import it into core schema
		puts 'in environment...'
		
		# variables
		rex_rm_whitespace = /(\n|\t|edit|)/
		rex_before_comma = /[^,]+/
	
	
		main_table_arha = Array.new
		competitors_table_arar = Array.new
		funding_table_arar = Array.new	
		acq_table_arar = Array.new
		inv_table_arar = Array.new
		people_table_arar = Array.new

###	
	puts 'Beginning scrape...'
	counter = 1	
		# strart individual company page scrape
	  	profile_page_scraper = Nokogiri::HTML(open("http://www.crunchbase.com/company/glenwood-group"))

		# pull company info from middle column --> going in main table
		main_table_hash = Hash.new
		company_name = profile_page_scraper.css('h1.h1_first').text.gsub(rex_rm_whitespace, '').strip
		profile_page_scraper.css('div#col2_internal p').empty? ? blurb = 'Null' : blurb = profile_page_scraper.css('div#col2_internal p').text
		profile_page_scraper.css('div#col2_internal table tr td a').empty? ? products = 'Null' : products = profile_page_scraper.css('div#col2_internal table tr td a').map{|obj| obj.text}.join(', ')			# used map to get comma-sep values, scraper was converting each value into a single string
		main_table_hash = main_table_hash.merge({:co_name => company_name, :blurb => blurb, :products => products})
####

		# grabbing the general info in the left column --> also going in the main table	
		gen_info = Hash.new

		profile_page_scraper.css("div.col1_content").each do |x|
			for i in 0..x.css("td.td_left").size  
				if x.css("td.td_left")[i] != nil  || x.css("td.td_right")[i] != nil
					gen_info[x.css("td.td_left")[i].text.downcase] = x.css("td.td_right")[i].text
					# puts "key: #{x.css("td.td_left")[i].text}, val: #{x.css("td.td_right")[i].text}"
				end
			end
		end
		p gen_info
		# strips all relevant data, conditional checks that they are not nil, if nil sets value to null
	puts '0'
		if gen_info['public'].nil? 
		       	ticker = 'Null' 
		else	
			if gen_info['public'] =~ /:\w+/
				ticker = gen_info['public'].match(/:\w+/)[0] 
				ticker = ticker[1,ticker.length]
			elsif gen_info['public'] =~ /:\s+/
				ticker = gen_info['public'].match(/:\s+\w+/)[0].match(/[a-z.]+/i)[0]
			else
				ticker = gen_info['public']
		
			end
		end
	puts ticker
		gen_info['website'] .nil? ? website = 'Null'  : website = gen_info['website'] 
	puts '2'
		gen_info['category'].nil? ? category = 'Null' : category = gen_info['category'] 
	puts '3'
		if gen_info['employees'] =~ (/[0-9]+(,[0-9]+)*/) 
				employees = gen_info['employees'].match(/[0-9]+(,[0-9]+)*/)[0].gsub(',', '').to_i
			else 
				employees = 'Null' 
		end
	puts 'halfway through gen info'
		gen_info['description'].nil? ? description = 'Null' : description = gen_info['description']
		gen_info['founded'].nil? ? founded = 'Null' : founded = normalize_date(gen_info['founded']) 
		p "Founded: #{founded}"
		
		main_table_hash = main_table_hash.merge({:ticker => ticker, :website => website, :category => category, :employees => employees, :description=> description, :founded => founded})
		main_table_arha << main_table_hash

####			
		puts "\tscraped gen info"

		# sub scrapers, scrapes all of the left column data into the scraped hash; use to scrape individual sections (people, investments, funding, etc.)
		scraped_hash = Hash.new
		col1_headers = profile_page_scraper.css("div#col1 h2") #text.strip.gsub(/(\n|\t|edit)/, '')
		col1_content = profile_page_scraper.css("div#col1 div.col1_content")

		for i in 0..col1_headers.size-1 do
			header = col1_headers[i].text.gsub(rex_rm_whitespace, '').strip.downcase
			content = col1_content[i]
			scraped_hash[header] = content
		end

	# competitors table scrape --> makes sure the section exists before checking; .empty? array means nothing provided
		if !scraped_hash['competitors'].nil? 
			scraped_hash['competitors'].css('a').each do |comps|
				competitors_row = [company_name, comps.text.strip]
				competitors_table_arar << competitors_row
			end
		end

####
		puts "\tscraped competitors"

	# funding table scrape --> checks if the section exists before running;, .empty? array means nothing provided
		if !scraped_hash['funding'].nil? 
			funding_row = Array.new
			fund_id = 0												#unique to each company
			scraped_hash['funding'].css('tr').each do |html|
				round= html.css('td.td_left2').text.scan(rex_before_comma).first.downcase
				if html.css('td.td_left2').text.scan(/\d+/)[0].nil?
					inv_date = 'Null'
					else	inv_date = "#{html.css('td.td_left2').text.scan(/\d+/)[0]}/01/#{html.css('td.td_left2').text.scan(/\d+/)[1]}"
				end
				involved_ents = html.css('td.td_left2 a').map{|ent| ent.text}
				amount = html.css('td.td_right2').text.strip
				p "Amount: #{amount}"
				# normalizes the amount funded (converts to int, appends right amount of 000's)
				amount.empty? ? normalized_amount = 'Null' : normalized_amount = normalize_money(amount)	
				p "Norm Amount: #{normalized_amount}"
				# INPUT - inputs to the funding table array
				if involved_ents.size > 0
					involved_ents.each do |ent|
						# table = company, invest ent, investing cohort, investing cohort id, round, cohort amount, date invested
						funding_row = [company_name, ent, involved_ents.join(', '), fund_id, round, normalized_amount, inv_date]
						funding_table_arar << funding_row
					end
				else 
					funding_row = [company_name, 'Null', 'Null', fund_id, round, normalized_amount, inv_date]
					funding_table_arar << funding_row
				end
								fund_id += 1
			end
			puts 'FUNDING:'
				funding_table_arar.each do |row|
				p row
			end

		end
		
####
		puts "\tscraped funding"

	# scraping the people section of the page profiles --> to be put in the people table	
		if !scraped_hash['people'].nil? 
			row_array = Array.new
			ppl_list = scraped_hash['people'].css('div.col1_people_name')
			title_list = scraped_hash['people'].css('div.col1_people_title')
			for i in 0..ppl_list.size-1 do 
				prsn = ppl_list[i].css('a').text
				title = title_list[i].text
				row_array = [company_name, prsn, title]
				people_table_arar << row_array
			end
		end
		
####
		puts "\tscraped people"

	# scraping the acquisitions section of the page profiles --> to be put in the acquisitions table	
		if !scraped_hash['acquisitions'].nil? 
			row_array = Array.new
			scraped_hash['acquisitions'].css('tr').each do |html|		
				if !html.css('td.td_left2').text.match(/\d+\/\d+/).nil? 
						date= html.css('td.td_left2').text.match(/\d+\/\d+/)
						company_acquired  = date.pre_match[0,date.pre_match.length-2]
						date = normalize_date date[0]
				else
						company_acquired = html.css('td.td_left2').text.match(rex_before_comma)[0]
						date = 'Null'
				end
				amount = html.css('td.td_right2').text.gsub(rex_rm_whitespace, '').strip.empty? ? 'Null' : normalize_money(html.css('td.td_right2').text.gsub(rex_rm_whitespace, '').strip)
				row_array = [company_name, company_acquired, date, amount]
				p row_array
				acq_table_arar << row_array
			end
		end
		
####
		puts "\tscraped acquisitions"

	# scraping the investments section of the page profiles --> to be put in the investments table	
		if !scraped_hash['investments'].nil? 
			row_array = Array.new
			scraped_hash['investments'].css('tr').each do |html|		
				invested_company = html.css('td.td_left2').text.strip
				row_array = [company_name, invested_company, date_invested]
				inv_table_arar << row_array
			end
		end	
		
####
		puts "\tscraped investments"
		counter += 1
		
	# begin inserting into core schema
	# create general info table, and begin inserting
		puts 'Finished without error.'	
	end
###################################################################################################################
	
	desc '--testing scipt single page scrape and entry into the db'
	task :single_to_db => [:environment,'crunch_dep:crunchmethods'] do

		# next up, gems are already applied, run test to scrape a page, then import it into core schema
		puts 'in environment...'
	 	time_start = Time.now.inspect

		# variables
		rex_rm_whitespace = /(\n|\t|edit)/
		rex_before_comma = /[^,]+/

		main_table_arha = Array.new
		competitors_table_arar = Array.new
		funding_table_arar = Array.new	
		acq_table_arar = Array.new
		inv_table_arar = Array.new
		people_table_arar = Array.new
		scrape_error_array = Array.new
	###	
		puts 'Beginning scrape...'
		counter = 1	
		timeout_counter = 0	
		# strart individual company page scrape
		begin 
			profile_page_scraper = Nokogiri::HTML(open("http://www.crunchbase.com/company/facebook"))

			# pull company info from middle column --> going in main table
			main_table_hash = Hash.new
			company_name = profile_page_scraper.css('h1.h1_first').text.gsub(rex_rm_whitespace, '').strip
			profile_page_scraper.css('div#col2_internal p').empty? ? blurb = 'Null' : blurb = profile_page_scraper.css('div#col2_internal p').text
			profile_page_scraper.css('div#col2_internal table tr td a').empty? ? products = 'Null' : products = profile_page_scraper.css('div#col2_internal table tr td a').map{|obj| obj.text}.join(', ')			# used map to get comma-sep values, scraper was converting each value into a single string
			main_table_hash = main_table_hash.merge({:co_name => company_name, :blurb => blurb, :products => products})
	####
			puts "Company: '#{company_name}'\n"
			# grabbing the general info in the left column --> also going in the main table	
			gen_info = Hash.new

			profile_page_scraper.css("div.col1_content").each do |x|
				for i in 0..x.css("td.td_left").size  
					if x.css("td.td_left")[i] != nil  || x.css("td.td_right")[i] != nil
						gen_info[x.css("td.td_left")[i].text.downcase] = x.css("td.td_right")[i].text
						# puts "key: #{x.css("td.td_left")[i].text}, val: #{x.css("td.td_right")[i].text}"
					end
				end
			end
			
			puts "\tnormalizing gen info"	
			# strips all relevant data, conditional checks that they are not nil, if nil sets value to null
			if gen_info['public'].nil?  
				ticker = 'Null'  
			else     
				if gen_info['public'] =~ /:\w+/
					ticker = gen_info['public'].match(/:\w+/)[0] 
					ticker = ticker[1,ticker.length]
				elsif gen_info['public'] =~ /:\s+/
					ticker = gen_info['public'].match(/:\s+\w+/)[0].match(/[a-z]+/i)[0]
				else
					ticker = gen_info['public']
			
				end
			end

			gen_info['website'] .nil? ? website = 'Null'  : website = gen_info['website'] 
			gen_info['category'].nil? ? category = 'Null' : category = gen_info['category'] 
			if gen_info['employees'] =~ (/[0-9]+(,[0-9]+)*/) 
					employees = gen_info['employees'].match(/[0-9]+(,[0-9]+)*/)[0].gsub(',', '').to_i
				else 
					employees = 'Null' 
			end
			gen_info['description'].nil? ? description = 'Null' : description = gen_info['description']
			gen_info['founded'].nil? ? founded = 'Null' : founded = normalize_date(gen_info['founded'])
			main_table_hash = main_table_hash.merge({:ticker => ticker, :website => website, :category => category, :employees => employees, :description=> description, :founded => founded})
			main_table_arha << main_table_hash

	####			
			puts "\tscraped gen info"

			# sub scrapers, scrapes all of the left column data into the scraped hash; use to scrape individual sections (people, investments, funding, etc.)
			scraped_hash = Hash.new
			col1_headers = profile_page_scraper.css("div#col1 h2") #text.strip.gsub(/(\n|\t|edit)/, '')
			col1_content = profile_page_scraper.css("div#col1 div.col1_content")

			for i in 0..col1_headers.size-1 do
				header = col1_headers[i].text.gsub(rex_rm_whitespace, '').strip.downcase
				content = col1_content[i]
				scraped_hash[header] = content
			end

		# competitors table scrape --> makes sure the section exists before checking; .empty? array means nothing provided
			if !scraped_hash['competitors'].nil? 
				scraped_hash['competitors'].css('a').each do |comps|
					competitors_row = [company_name, comps.text.strip]
					competitors_table_arar << competitors_row
				end
			end

	####
			puts "\tscraped competitors"

		# funding table scrape --> checks if the section exists before running;, .empty? array means nothing provided
			if !scraped_hash['funding'].nil? 
				funding_row = Array.new
				fund_id = 0												#unique to each company
				scraped_hash['funding'].css('tr').each do |html|
					round= html.css('td.td_left2').text.scan(rex_before_comma).first.downcase
					if html.css('td.td_left2').text.scan(/\d+/)[0].nil?
						inv_date = 'Null'
						else inv_date = normalize_date("#{html.css('td.td_left2').text.match(/\d+(\/\d+)*/)[0]}")
					end
					puts "Orig text pulled:#{html.css('td.td_left2').text}"

						
					involved_ents = html.css('td.td_left2 a').map{|ent| ent.text}
					amount = html.css('td.td_right2').text.strip
					# normalizes the amount funded (converts to int, appends right amount of 000's)
					amount.empty? ? normalized_amount = 'Null' : normalized_amount = normalize_money(amount)	
					# INPUT - inputs to the funding table array
					if involved_ents.size > 0
						involved_ents.each do |ent|
							# table = company, invest ent, investing cohort, investing cohort id, round, cohort amount, date invested
							funding_row = [company_name, ent, involved_ents.join(', '), fund_id, round, normalized_amount, inv_date]
							funding_table_arar << funding_row
						end
					else 
						funding_row = [company_name, 'Null', 'Null', fund_id, round, normalized_amount, inv_date]
						funding_table_arar << funding_row
					end
					fund_id += 1
				end
			end
			funding_table_arar.each do |row|
				p row
			end
	####
			puts "\tscraped funding"

		# scraping the people section of the page profiles --> to be put in the people table	
			if !scraped_hash['people'].nil? 
				row_array = Array.new
				ppl_list = scraped_hash['people'].css('div.col1_people_name')
				title_list = scraped_hash['people'].css('div.col1_people_title')
				for i in 0..ppl_list.size-1 do 
					prsn = ppl_list[i].css('a').text
					title = title_list[i].text
					row_array = [company_name, prsn, title]
					people_table_arar << row_array
				end
			end
			
	####
			puts "\tscraped people"

		# scraping the acquisitions section of the page profiles --> to be put in the acquisitions table	
			if !scraped_hash['acquisitions'].nil? 
				row_array = Array.new
				scraped_hash['acquisitions'].css('tr').each do |html|		
					if !html.css('td.td_left2').text.match(/,\s*\d+(.\d+)*/).nil? 
						date = html.css('td.td_left2').text.match(/,\s*\d+(.\d+)*/)[0]
						p "date_raw = '#{date}'"
						date = date.match(/\d+(.\d+)*/)[0]
						p date
						company_acquired  = html.css('td.td_left2').text.match(/,\s*\d+(.\d+)*/).pre_match
						date = normalize_date date
					else
							company_acquired = html.css('td.td_left2').text.match(rex_before_comma)[0]
							date = 'Null'
					end
					puts "Original: '#{html.css('td.td_right2').text.gsub(rex_rm_whitespace, '').strip}'"
					amount = html.css('td.td_right2').text.gsub(rex_rm_whitespace, '').strip.empty? ? 'Null' : normalize_money(html.css('td.td_right2').text.gsub(rex_rm_whitespace, '').strip)
					puts "Amount: #{amount}"
					row_array = [company_name, company_acquired, date, amount]
					p row_array
					acq_table_arar << row_array
				end
			end
			
			puts "\tscraped acquisitions"

		# scraping the investments section of the page profiles --> to be put in the investments table	
			if !scraped_hash['investments'].nil? 
				row_array = Array.new
				scraped_hash['investments'].css('tr').each do |html|		
					invested_company = html.css('td.td_left2').text.strip
					html.css('td.td_right2').text.gsub(rex_rm_whitespace, '').strip.empty? ? date_invested =  'Null' : date_invested = normalize_date(html.css('td.td_right2').text.gsub(rex_rm_whitespace, '').strip)
					row_array = [company_name, invested_company, date_invested]
					inv_table_arar << row_array
				end
			end	
			counter += 1
		rescue Timeout::Error
			puts "~~~~~~~~~~~~~~Rescuing Timeout Error ##{timeout_counter += 1}"
			sleep(60)
			puts "timeout rescued"
			retry
		rescue => e
			puts "Error, scraping company - '#{company_name}'"
			puts e.message
			sleep(60)	
			scrape_error_array << e.message
			next
		end

		puts "\n\nDone scraping, #{timeout_counter} number of timeout errors"
		time_scrape = Time.now.inspect
		db_error_array = Array.new
		
		puts "\n\nInserting into DB"
		
		# begin inserting into core schema
		# create general info table, and begin inserting
		ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS scarr.tmp_crunch_main; CREATE TABLE scarr.tmp_crunch_main (crunch_ent_name VARCHAR(256),ticker VARCHAR(64),employees INTEGER,founded DATE,website VARCHAR(256),category VARCHAR(32),products TEXT,description VARCHAR(256),blurb TEXT);")
		puts "Inserting #{main_table_arha.size} main table entries"
		main_table_arha.each do |company_info|
			begin
				ActiveRecord::Base.connection.execute("INSERT INTO scarr.tmp_crunch_main(crunch_ent_name,ticker,employees,founded,website,category,products,description,blurb) VALUES(#{db_str_entry company_info[:co_name]},#{db_str_entry company_info[:ticker]},#{db_int_entry company_info[:employees]},#{db_str_entry company_info[:founded]},#{db_str_entry company_info[:website]},#{db_str_entry company_info[:category]},#{db_str_entry company_info[:products]},#{db_str_entry company_info[:description]},#{db_str_entry company_info[:blurb]})");
			rescue => e	
			        puts "~~ERROR: #{e.message}"
			       	db_error_array << e.message
			        next
			end
		end	
		puts 'Finished inserting main table'

		# create and add competitors table
		ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS scarr.tmp_crunch_competitors; CREATE TABLE scarr.tmp_crunch_competitors (crunch_ent_name VARCHAR(256),competitor VARCHAR(256));")
		puts "Inserting #{competitors_table_arar.size} competitor entries"
		competitors_table_arar.each do |co|
			begin
				ActiveRecord::Base.connection.execute("INSERT INTO scarr.tmp_crunch_competitors(crunch_ent_name,competitor) VALUES(#{db_str_entry co[0]},#{db_str_entry co[1]});")
			rescue => e	
			        puts "~~ERROR: #{e.message}"
				db_error_array << e.message
			        next
			end
		end
		puts 'Finished inserting competitors'

		
		# create and add funding table
		ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS scarr.tmp_crunch_funding; CREATE TABLE scarr.tmp_crunch_funding(crunch_ent_name VARCHAR(256),investing_entity VARCHAR(256),investing_cohort TEXT, cohort_id INTEGER,round VARCHAR(256),cohort_amount BIGINT, date_invested DATE);")
		puts "Inserting #{funding_table_arar.size} funding entries"
		funding_table_arar.each do |row|
			begin
				ActiveRecord::Base.connection.execute("INSERT INTO scarr.tmp_crunch_funding (crunch_ent_name,investing_entity,investing_cohort,cohort_id,round,cohort_amount,date_invested) VALUES(#{db_str_entry row[0]},#{db_str_entry row[1]},#{db_str_entry row[2]},#{db_int_entry row[3]},#{db_str_entry row[4]},#{db_int_entry row[5]},#{db_str_entry row[6]});")
			rescue => e	
			        puts "~~ERROR: #{e.message}"
				puts "\tComp Name: #{row[0]}\n\tInvesting Ent: #{row[1]}\n\tInvesting Cohort: #{row[2]}\n\tCohort id: #{row[3]}\n\tRound: #{row[4]}\n\tAmount: #{row[5]}\n\tDate: #{row[6]}\n\n"
				db_error_array << e.message
			        next
			end
		end
		puts 'Finished inserting funding'

		
		# create and add acquisition table	
		ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS scarr.tmp_crunch_acquisitions; CREATE TABLE scarr.tmp_crunch_acquisitions(crunch_ent_name VARCHAR(256),acquired_crunch_ent_name VARCHAR(256),date_acquired DATE,amount BIGINT);")
		puts "Inserting #{acq_table_arar.size} acquisition entries"
		acq_table_arar.each do |row|
			begin
				ActiveRecord::Base.connection.execute("INSERT INTO scarr.tmp_crunch_acquisitions (crunch_ent_name,acquired_crunch_ent_name,date_acquired,amount) VALUES(#{db_str_entry row[0]},#{db_str_entry row[1]},#{db_str_entry row[2]},#{db_int_entry row[3]});")
			rescue => e	
			        puts "~~ERROR: #{e.message}"
				db_error_array << e.message
			        next
			end
		end
		puts 'Finished inserting acq'
		
		
		# create and add investment table
		ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS scarr.tmp_crunch_investments; CREATE TABLE scarr.tmp_crunch_investments(crunch_ent_name VARCHAR(256),invested_crunch_ent_name VARCHAR(256),date_invested DATE);")
		puts "Inserting #{inv_table_arar.size} investment entries"
		inv_table_arar.each do |row|
			begin
				ActiveRecord::Base.connection.execute("INSERT INTO scarr.tmp_crunch_investments (crunch_ent_name,invested_crunch_ent_name,date_invested) VALUES(#{db_str_entry row[0]},#{db_str_entry row[1]},#{db_str_entry row[2]});")
			rescue => e	
			        puts "~~ERROR: #{e.message}"
				puts "\tInvesting Comp Name: #{row[0]}\n\tInvested Comp Name: #{row[1]}\n\tDate Invested: #{row[2]}\n"
				db_error_array << e.message
		   	       	next
			end
		end
		puts 'Finished inserting investments'
		
		
		# create and add people table	
		ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS scarr.tmp_crunch_people; CREATE TABLE scarr.tmp_crunch_people(crunch_ent_name VARCHAR(256),person VARCHAR(256),title VARCHAR(256));")
		puts "Inserting #{people_table_arar.size} people entries"
		people_table_arar.each do |row|
			begin
				ActiveRecord::Base.connection.execute("INSERT INTO scarr.tmp_crunch_people (crunch_ent_name,person,title) VALUES(#{db_str_entry row[0]},#{db_str_entry row[1]},#{db_str_entry row[2]});")
			rescue => e	
			       	puts "~~ERROR: #{e.message}"
				db_error_array << e.message
			       	next
			end
		end
		puts 'Finished inserting people'


		
		
		
		time_finish = Time.now.inspect	
		puts 'Finished.'	
		puts "Time Started: #{time_start}\nScrape Finished at: #{time_scrape}\nScript Finish at: #{time_finish}\n\nDB Errors:"
		db_error_array.each do |msg|
			puts "DB Error Message: #{msg}\n\n"
		end

		puts "\n\nScraping Errors:"
		scrape_error_array.each do |msg|
			puts "Scrape Error Message: #{msg}\n\n"
		end
	end	
	end 
