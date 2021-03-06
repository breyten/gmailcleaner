require 'rubygems'
require 'time'
require 'bundler'

require 'gmail'
require 'inifile'

config = IniFile.load('config.ini')

rules = config.sections.reject{ |section| section == 'auth' }

Gmail.connect(config['auth']['user'], config['auth']['password']) do |gmail|
  rules.each do |rule|
    passes = []
    puts rule

    if config[rule].has_key?('subject')
      subjects = config[rule]['subject'].split(',')
      subjects.each do |subject|
        passes << {
          :subject => subject
        }
      end
    else
      passes << {}
    end
    
    if config[rule].has_key?('from')
      passes.each do |pass|
        pass[:from] = config[rule]['from']
      end
    end

    if config[rule].has_key?('delay')
       delay = config[rule]['delay'].to_i
    else
      delay = 86400
    end
    passes.each do |pass|
      pass[:before] = Time.new - delay
    end

    action = config[rule]['action'] || 'delete'

    passes.each do |pass|
      if config[rule].has_key?('label')
        mailbox = gmail.mailbox(config[rule]['label'])
      else
        mailbox = gmail.inbox
      end
      subject_count = mailbox.search(pass).count
      puts pass[:subject], subject_count, action
      mailbox.search(pass).each do |email|
        puts email.subject
        if action == 'archive'
          email.archive!
        elsif action == 'delete'
          email.delete!
        end
      end
    end
  end
end