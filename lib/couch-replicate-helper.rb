require 'couchrest'

class CouchReplicate
  # database =  'http://127.0.0.1:5984/dbname'
  def initialize(database)
    @db = CouchRest.database(database)
  end

  # name with suffix, suffix
  def replicate(source, dest)
    puts "going to replicate #{source} to dest #{dest}"
    unless is_active? source, dest
      puts "triggering replication..."
      RestClient.post @db.host + '/_replicate', {:source => source, :target => dest, :continuous => true }.to_json, :content_type => "Content-Type: application/json"
    end
  end

  private

  def is_active?(source, dest)
    tasks = CouchRest.get(@db.server.uri + '/_active_tasks')
    tasks.each do |t|
      puts "#{t['type']} #{t['task']} #{t['status']} #{t['pid']}"
    end
    tasks.find { |t| t['type'] == 'Replication' and t['task'].scan source and t['task'].scan dest }
  end
end
