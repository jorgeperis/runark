class RunsController < ApplicationController
  before_action :set_run, only: %i[ show edit update destroy ]

  # GET /runs or /runs.json
  def index
    @runs = current_user.runs.ordered
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
      params[:run][:time] = Run.time_from_components(
        hours:   params[:run].delete(:time_hours),
        minutes: params[:run].delete(:time_minutes),
        seconds: params[:run].delete(:time_seconds)
      )

      params.expect(run: [ :race_id, :date, :distance, :homologated, :time ])
    end
end
