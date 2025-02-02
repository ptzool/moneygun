class EmployeeDocumentTypesController < ApplicationController
  before_action :set_employee_document_type, only: [:show, :edit, :update, :destroy]

  # GET /employee_document_types
  def index
    @employee_document_types = EmployeeDocumentType.all

    # Uncomment to authorize with Pundit
    # authorize @employee_document_types
  end

  # GET /employee_document_types/1 or /employee_document_types/1.json
  def show
  end

  # GET /employee_document_types/new
  def new
    @employee_document_type = EmployeeDocumentType.new

    # Uncomment to authorize with Pundit
    # authorize @employee_document_type
  end

  # GET /employee_document_types/1/edit
  def edit
  end

  # POST /employee_document_types or /employee_document_types.json
  def create
    @employee_document_type = EmployeeDocumentType.new(employee_document_type_params)

    # Uncomment to authorize with Pundit
    # authorize @employee_document_type

    respond_to do |format|
      if @employee_document_type.save
        format.html { redirect_to @employee_document_type, notice: "Employee document type was successfully created." }
        format.json { render :show, status: :created, location: @employee_document_type }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @employee_document_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /employee_document_types/1 or /employee_document_types/1.json
  def update
    respond_to do |format|
      if @employee_document_type.update(employee_document_type_params)
        format.html { redirect_to @employee_document_type, notice: "Employee document type was successfully updated." }
        format.json { render :show, status: :ok, location: @employee_document_type }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @employee_document_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /employee_document_types/1 or /employee_document_types/1.json
  def destroy
    @employee_document_type.destroy!
    respond_to do |format|
      format.html { redirect_to employee_document_types_url, status: :see_other, notice: "Employee document type was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_employee_document_type
    @employee_document_type = EmployeeDocumentType.find(params[:id])

    # Uncomment to authorize with Pundit
    # authorize @employee_document_type
  rescue ActiveRecord::RecordNotFound
    redirect_to employee_document_types_path
  end

  def employee_document_type_params
    params.require(:employee_document_type).permit(:name)

    # Uncomment to use Pundit permitted attributes
    # params.require(:employee_document_type).permit(policy(@employee_document_type).permitted_attributes)
  end
end
