class RunMarksController < ApplicationController
  before_action :set_run_mark, only: %i[ show edit update destroy ]

  # GET /run_marks or /run_marks.json
  def index
    @run_marks = current_user.run_marks.ordered
  end

  # GET /run_marks/1 or /run_marks/1.json
  def show
  end

  # GET /run_marks/new
  def new
    @run_mark = RunMark.new
  end

  # GET /run_marks/1/edit
  def edit
  end

  # POST /run_marks or /run_marks.json
  def create
    @run_mark = current_user.run_marks.new(run_mark_params)

    respond_to do |format|
      if @run_mark.save
        format.html { redirect_to @run_mark, notice: "Run mark was successfully created." }
        format.json { render :show, status: :created, location: @run_mark }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @run_mark.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /run_marks/1 or /run_marks/1.json
  def update
    respond_to do |format|
      if @run_mark.update(run_mark_params)
        format.html { redirect_to @run_mark, notice: "Run mark was successfully updated." }
        format.json { render :show, status: :ok, location: @run_mark }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @run_mark.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /run_marks/1 or /run_marks/1.json
  def destroy
    @run_mark.destroy!

    respond_to do |format|
      format.html { redirect_to run_marks_path, status: :see_other, notice: "Run mark was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_run_mark
      @run_mark = current_user.run_marks.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def run_mark_params
      hours = params[:run_mark].delete(:time_hours)
      minutes = params[:run_mark].delete(:time_minutes)
      seconds = params[:run_mark].delete(:time_seconds)

      params[:run_mark][:time] = hours.to_i * 3600 + minutes.to_i * 60 + seconds.to_i

      params.expect(run_mark: [ :race_id, :edition, :date, :distance, :homologated, :time, :source ])
    end
end
