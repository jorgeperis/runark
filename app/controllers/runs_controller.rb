class RunsController < ApplicationController
  before_action :set_run, only: %i[ show edit update destroy ]

  # GET /runs or /runs.json
  def index
    @sort      = params[:sort].presence_in(Run::SORTABLE_COLUMNS.keys) || "date"
    @direction = params[:direction] == "asc" ? "asc" : "desc"

    @runs = current_user.runs
      .search_name(params[:q])
      .for_year(params[:year])
      .for_distance(params[:distance])
      .for_race(params[:race_id])
      .sorted_by(@sort, @direction)
      .includes(:race)

    @years      = current_user.runs.distinct.pluck(Arel.sql("strftime('%Y', date)")).compact.sort.reverse
    @distances  = current_user.runs.distinct.order(:distance).pluck(:distance)
    @races      = Race.canonical.order(:name)
    @best_times = current_user.runs.group(:distance).minimum(:time)
  end

  # GET /runs/1 or /runs/1.json
  def show
  end

  # GET /runs/new
  def new
    @run = Run.new
  end

  # GET /runs/1/edit
  def edit
  end

  # POST /runs or /runs.json
  def create
    @run = current_user.runs.new(run_params)

    respond_to do |format|
      if @run.save
        format.html { redirect_to @run, notice: "Run was successfully created." }
        format.json { render :show, status: :created, location: @run }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @run.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /runs/1 or /runs/1.json
  def update
    @run.image.purge_later if params.dig(:run, :remove_image) == "1"

    respond_to do |format|
      if @run.update(run_params)
        format.html { redirect_to @run, notice: "Run was successfully updated." }
        format.json { render :show, status: :ok, location: @run }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @run.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /runs/1 or /runs/1.json
  def destroy
    @run.destroy!

    respond_to do |format|
      format.html { redirect_to runs_path, status: :see_other, notice: "Run was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_run
      @run = current_user.runs.find(params.expect(:id))
    end

    def run_params
      params.expect(run: [ :race_id, :date, :distance, :time_formatted, :image ])
    end
end
