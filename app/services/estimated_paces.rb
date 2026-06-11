class EstimatedPaces
  def self.for(run, distances = FAVOURITE_RACE_DISTANCES.keys)
    self.new(run, distances).calculate
  end

  def initialize(run, distances)
    @run = run
    @distances = distances
  end

  def calculate
    @distances.each_with_object({}) do |distance, result|
      result[distance] = calculate_time(distance)
    end
  end

  private

  def calculate_time(distance)
    # Riegel Formula: https://en.wikipedia.org/wiki/Peter_Riegel
    @run.time * ((distance.to_f / @run.distance) ** 1.06)
  end
end
