# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
namespace :report do
  desc 'Generate a download/view count report'
  task :downloads_and_views, %i[start end] => :environment do |_, args|
    args.with_defaults(start: '2024-01-01', end: DateTime.now.strftime)

    # get view and download counts by druid, but only count them once per visit
    # e.g. if a user visits a druid five times in what ahoy considers a unique visit
    # it will only be counted once. this matches the counts you see in purl.

    # support filtering by druids if provided
    druid_filter = if ENV['DRUIDS'].present?
                     "AND druid IN (#{ENV['DRUIDS'].split(',').map do |d|
                       ActiveRecord::Base.connection.quote(d.strip)
                     end.join(', ')})"
                   end

    sql = <<~SQL.squish
      SELECT druid, name, COUNT(*) AS count
      FROM (
        SELECT druid, visit_id, name
        FROM ahoy_events
        WHERE time >= $1
        AND time <= $2
        #{druid_filter}
        GROUP BY druid, visit_id, name
      ) AS events
      GROUP BY druid, name
      ORDER BY druid
    SQL

    puts 'druid,view_count,download_count'

    last_druid = nil
    stats = { view: 0, download: 0 }

    ActiveRecord::Base.connection.exec_query(sql, 'downloads_and_views', [args.start, args.end]).each do |row|
      # accumulate view and download stats by druid on a single row
      if last_druid && row['druid'] != last_druid
        puts "#{last_druid},#{stats['view']},#{stats['download']}"
        stats = { view: 0, download: 0 }
        last_druid = row['druid']
      end

      last_druid = row['druid']
      event_type = row['name'] == '$view' ? 'view' : 'download'
      stats[event_type] = row['count']
    end

    # output the final druid
    puts "#{last_druid},#{stats['view']},#{stats['download']}" if last_druid
  end

  desc 'Generate a unique event report'
  task :unique_events, %i[start end] => :environment do |_, args|
    args.with_defaults(start: '2024-01-01', end: DateTime.now.strftime)

    # get each event for a druid, but only count them once per visit/event type
    # e.g. if a user views a druid twice and then downloads it, list the
    # first view and the download. this matches the counts you see in purl.

    # support filtering by druids if provided
    druid_filter = if ENV['DRUIDS'].present?
                     "AND druid IN (#{ENV['DRUIDS'].split(',').map do |d|
                       ActiveRecord::Base.connection.quote(d.strip)
                     end.join(', ')})"
                   end

    sql = <<~SQL.squish
      SELECT MIN(time) as visit_time, druid, name, visit.ip
      FROM ahoy_events
      JOIN ahoy_visits AS visit ON ahoy_events.visit_id = visit.id
      WHERE time >= $1
      AND time <= $2
      #{druid_filter}
      GROUP BY druid, visit_id, name, visit.ip
      ORDER BY visit_time
    SQL

    puts 'visit_time,druid,anonymized_ip,event_type'

    ActiveRecord::Base.connection.exec_query(sql, 'downloads_and_views', [args.start, args.end]).each do |row|
      event_type = row['name'] == '$view' ? 'view' : 'download'
      puts "#{row['visit_time']},#{row['druid']},#{row['ip']},#{event_type}"
    end
  end
end
# rubocop:enable Metrics/BlockLength
