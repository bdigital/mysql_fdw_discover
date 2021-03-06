#
# Define and parse options
#

options = {}
PARSER = OptionParser.new do |opts|
  opts.banner = "Usage: ./discover.rb [options]"

  opts.on("-c", "--config-file [STRING]", "a yaml file with connection options see example.config.yml") do |d|
    options[:config_file] = d
  end

  opts.on("-d", "--database [STRING]", "mysql database name to translate") do |d|
    options[:database] = d
  end
  
  opts.on("-u", "--username [STRING]", "user name to connect to mysql") do |u|
    options[:username] = u
  end
  
  opts.on("-h", "--host [STRING]", "host to connect to mysql") do |u|
    options[:host] = u
  end
  
  opts.on("-P", "--port [STRING]", "port to connect to mysql") do |p|
    options[:port] = p
  end
  
  opts.on("-p", "--password [STRING]", "password to connect to mysql") do |p|
    options[:password] = p
  end

  opts.on("-s", "--destination-schema [STRING]", "schema of pg database to port the mysql tables") do |s|
    options[:schema] = s
  end
  
  opts.on("-m", "--mirror-schema [STRING]", "creates schema of this name and sql to copy all foreign data to the mirror schema.") do |s|
    options[:mirror_schema] = s
  end
  
  opts.on("-r", "--replace_tables", "drops tables before creating tables") do |s|
    options[:replace] = s
  end
  
  opts.on("-f", "--foreign_server [STRING]", "the name of the foreign server") do |f|
    options[:foreign_server] = f
  end
  
end

PARSER.parse!


#
# Build Conf hash
#

CONF = {'destination_schema' => 'public',
        'replace' => false,
        'mirror_schema' => nil,
        'host' => 'localhost',
        'foreign_server' => 'mysql_svr',
        'port' => 3306}

CONF.merge!(YAML::load(File.open(File.dirname(__FILE__) + "/../" + options[:config_file]))) if options[:config_file]

CONF.merge!('destination_schema' => options[:schema]) if options[:schema]
CONF.merge!('replace' => options[:replace]) if options[:replace]
CONF.merge!('mirror_schema' => options[:mirror_schema]) if options[:mirror_schema]
CONF.merge!('database_name' => options[:database]) if options[:database]
CONF.merge!('username' => options[:username]) if options[:username]
CONF.merge!('password' => options[:password]) if options[:password]
CONF.merge!('host' => options[:host]) if options[:host]
CONF.merge!('port' => options[:port]) if options[:port]
CONF.merge!('foreign_server' => options[:foreign_server]) if options[:foreign_server]

#
# Check some Error conditions
#

if options[:database].nil? && options[:config_file].nil?
  puts "must use -d or --database option, or specify a configuration file.  see --help for options."
  exit 1
end


if CONF['destination_schema'] == CONF['mirror_schema']
  puts "destination_schema and mirror_schema cannot be the same schema"
  exit 1
end 

