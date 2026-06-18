module ApplicationHelper
  def decorated_distance_for(distance)
    COMMON_RACE_DISTANCES[distance.to_s]&.fetch(:name) || distance_in_km(distance)
  end

  def distance_in_km(distance)
    distance.to_s + " km"
  end

  def decorated_time_for(time)
    time = time.round
    hours = time / 3600
    minutes = (time % 3600) / 60
    seconds = time % 60

    result = "#{minutes.to_i}'#{seconds.to_i.to_s.rjust(2, '0')}''"

    hours >= 1 ? "#{hours.to_i}h#{result}" : result
  end

  # Maps [[year, time], ...] to SVG coordinates for an inline progression chart.
  # Faster times sit higher on the chart, so an improving athlete trends upward.
  def progression_chart(entries, width:, height:, padding: 8)
    times = entries.map(&:last)
    min, max = times.min, times.max
    span = (max - min).to_f

    inner_w = width - padding * 2
    inner_h = height - padding * 2
    step = entries.size > 1 ? inner_w / (entries.size - 1.0) : 0

    points = entries.each_with_index.map do |(year, time), i|
      x = padding + step * i
      y = padding + (span.zero? ? inner_h / 2 : (time - min) / span * inner_h)
      { x: x.round(1), y: y.round(1), year: year, time: time }
    end

    { points: points, line: points.map { |p| "#{p[:x]},#{p[:y]}" }.join(" ") }
  end
end
