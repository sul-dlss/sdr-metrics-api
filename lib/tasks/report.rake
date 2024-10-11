# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
namespace :report do
  desc 'Generate a download/view report'
  task :downloads_and_views, %i[start end] => :environment do |_, args|
    args.with_defaults(start: '2024-01-01', end: DateTime.now.strftime)

    # get view and download counts by druid, but only count them once per visit
    # e.g. if a user visits a druid five times in what ahoy considers a unique visit
    # it will only be counted once. this matches the counts you see in purl.

    sql = <<~SQL.squish
      SELECT druid, name, COUNT(*) AS count
      FROM (
        SELECT druid, visit_id, name
        FROM ahoy_events
        WHERE time >= $1
        AND time <= $2
        GROUP BY druid, visit_id, name
      ) AS events
      GROUP BY druid, name
      ORDER BY druid
    SQL

    puts 'druid,view,download'

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
  end
end
# rubocop:enable Metrics/BlockLength
