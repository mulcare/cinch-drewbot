# Add to configure.do stanza:
#
#  config.plugins.options[Cinch::Drewbot] = {
#    :weechat_log => "/path/to/weechatlog/to/scan.txt",
#    :drew_log => "/path/to/log/with/extracted/lines.txt"
#    :drews => ["nick", "alt_nick"]
#  }


class Cinch::DrewBot
  include Cinch::Plugin

  listen_to :connect, method: :setup

  match /drew (.+)/, method: :extract
  match /drew\z/, method: :extract_without_query
  match /drew_update/, method: :update
  match /drew_stats/, method: :stats

  def setup(*)
    @weechat_log = config[:weechat_log]
    @drew_log = config[:drew_log]
    @drews = config[:drews]
  end

  def update(m)
    drews = @drews

    @linecount_before_update = linecount

    File.open(@drew_log, 'w+') {} # Start a fresh copy of log

    File.open(@weechat_log) do |log|
      log.each_line do |line|
        if drews.include? line.split(/\t/)[1].sub(/@/,'').sub(/+/,'')
          File.open(@drew_log, 'a') { |file| file << line }
        end
      end
    end

    @linecount_after_update = linecount

    m.reply "Updated. Added #{@linecount_after_update - @linecount_before_update} lines. Current total: #{@linecount_after_update} lines."

  end

  def linecount
    @lines = File.read(@drew_log).each_line.count
  end

  def date_range
    @earliest_date = `head -1 #{@drew_log}`
    @latest_date = `tail -1 #{@drew_log}`
  end

  def stats(m)
    linecount
    date_range
    m.reply "Total lines: #{@lines}"
    m.reply "Nicks tracked: #{@drews.count}"
    m.reply "Earliest line: #{@earliest_date}"
    m.reply "Latest line: #{@latest_date}"
  end

  def collect_lines
    @drew_lines = Array.new
    line_length = rand(100)
    File.foreach(@drew_log).each do |line|
      if line.length >= line_length
        @drew_lines.push(line)
      end
    end
  end

  def random_line
    @selected_line = @drew_lines.sample.split(/\t/)[2]
  end

  def query_lines(query)
    @drew_lines = Array.new
    File.foreach(@drew_log).each do |line|
      if line.downcase.split(/\t/)[2].include?(query.downcase)
        @drew_lines.push(line)
      end
    end
    if @drew_lines.empty?
      collect_lines
    end
  end

  def extract(m, q)
    if q
      query_lines(q)
    else
      collect_lines
    end
    random_line
    m.reply "#{@selected_line}"
  end

  def extract_without_query(m)
    collect_lines
    random_line
    m.reply "#{@selected_line}"
  end
end
