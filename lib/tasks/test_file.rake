namespace :mi do
 desc 'this is a test task that has access to database'
 task :test => :environment do
  puts 'testing...'
  ActiveRecord::Base.connection.execute("SELECT * INTO scarr.rails_test_table FROM shared.all_lits WHERE normalized_defendant ILIKE '%silver spring%';").to_a
 end
 
 task :test2 => :environment do
  puts 'in testing 2'
  x =  ActiveRecord::Base.connection.execute("SELECT * FROM shared.all_lits WHERE normalized_defendant ILIKE '%silver spring%';").to_a
  puts x.class
  ap x
 end 
end

