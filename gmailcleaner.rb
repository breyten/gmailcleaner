require 'rubygems'
require 'time'
require 'bundler'

require 'gmail'
require 'inifile'

start_time = Time.new - 2*86400
start_date = start_time.strftime('%y-%m-%d')
config = IniFile.load('config.ini')

Gmail.connect(config['auth']['user'], config['auth']['password']) do |gmail|
  subjects = ['alert', 'high']
  
  subjects.each do |subject|
    #puts gmail.inbox.search(:from => 'contact@stathat.com', :subject => subject, :before => start_date).count
    gmail.inbox.search(:from => 'contact@stathat.com',  :subject => subject, :before => start_date).each do |email|
      email.delete!
    end
  end
end