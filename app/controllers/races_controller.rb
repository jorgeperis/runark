class RacesController < ApplicationController
  before_action :set_race, only: %i[ show edit update destroy ]
  before_action :require_editable_race, only: %i[ edit update ]
  before_action :require_destroyable_race, only: %i[ destroy ]

  def index
    @races = Race.canonical.order(:name)
  end

  def show
  end

  def new
    @race = Race.new
  end

  def edit
  end

  def create
    @race = Race.new(race_params)

    respond_to do |format|
      if @race.save
        format.html { redirect_to @race, notice: "Race was successfully created." }
        format.json { render :show, status: :created, location: @race }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @race.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @race.update(race_params)
        format.html { redirect_to @race, notice: "Race was successfully updated." }
        format.json { render :show, status: :ok, location: @race }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @race.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @race.destroy!

    respond_to do |format|
      format.html { redirect_to races_path, status: :see_other, notice: "Race was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def search
    races = Race.search(params[:q].to_s)
    render json: races.map { |r| { value: r.id, text: "#{r.name} — #{r.location} (#{r.distance} km)" } }
  end

  private

  def set_race
    @race = Race.find(params.expect(:id))
  end

  def require_editable_race
    return if @race.runs.where.not(user_id: current_user.id).none?

    redirect_to @race, alert: "This race can't be edited because other runners have results on it."
  end

  def require_destroyable_race
    return if @race.runs.none?

    redirect_to @race, alert: "This race can't be deleted because it has run results attached."
  end

  def race_params
    params.expect(race: [ :name, :location, :distance ])
  end
end
