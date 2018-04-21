# lib/tasks/db.rake
namespace :pg do
  
  desc "Dumps the database to db/somefile"
  task :db_dump, [:file] => :environment do |t, args|
    cmd = nil
    with_config do |passwd, host, db, user|
      file = args[:file] || "db_#{db}_#{Time.now.strftime('%Y_%m_%d_%H_%M_%S')}.dump"
      cmd = "pg_dump -U #{user} -w --verbose --clean --no-owner --no-acl --format=c -f #{Rails.root}/db/#{file} #{db}"
    end
    system cmd
    puts cmd
    puts file
  end

  desc "Restores the database dump at db/somefile"
  task :db_restore, [:file, :confirm] => :environment do |t, args|
    confirm = args[:confirm] or raise 'Warning: this will call "rake db:drop" and "rake db:create" first!!! Please run: rake pg:db_restore[file_name,confirm]'
    file = args[:file] or raise 'Warning: this will call "rake db:drop" and "rake db:create" first!!! Please run: rake pg:db_restore[file_name,confirm]'
    cmd = nil
    with_config do |passwd, host, db, user|
      cmd = "pg_restore --verbose -U #{user} -w --clean --no-owner --no-acl --dbname #{db} #{Rails.root}/db/#{file}"
    end
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    system cmd
    puts cmd
    puts file
  end

  desc "Dumps tables to db/file"
  task :table_dump, [:table, :file] => :environment do |t, args|
    puts args
    cmd = nil
    table = args[:table] or raise 'Example: rake pg:table_dump[table_name,file_name]'
    tables = table.split(',')
    file = args[:file] || "table_#{tables.join('_')}_#{Time.now.strftime('%Y_%m_%d_%H_%M_%S')}.dump"
    with_config do |passwd, host, db, user|
      cmd = "pg_dump -U #{user} -w --verbose --clean --no-owner --no-acl --format=c -f #{Rails.root}/db/#{file} #{db}"
      if tables.present?
        tables.each do |table|
          cmd = cmd + " --table=#{table}"
        end
      end
    end
    system cmd
    puts cmd
    puts file
  end

  desc "Restores tables dump from db/file"
  task :table_restore, [:file, :confirm] => :environment do |t, args|
    confirm = args[:confirm] or raise 'Warning: this will drop some tables and recreate them!!! Please run: rake pg:table_restore[file_name,confirm]'
    file = args[:file] or raise 'Warning: this will drop some tables and recreate them!!! Please run: rake pg:table_restore[file_name,confirm]'
    cmd = nil
    with_config do |passwd, host, db, user|
      cmd = "pg_restore --verbose -U #{user} -w --clean --no-owner --no-acl --dbname #{db} #{Rails.root}/db/#{file}"
    end
    system cmd
    puts cmd
    puts file
  end

  private

  def with_config
    yield Rails.application.class.parent_name.underscore,
      ActiveRecord::Base.connection_config[:password],
      ActiveRecord::Base.connection_config[:database],
      ActiveRecord::Base.connection_config[:username]
  end

end