class SpaceController < ApplicationController
  def index
  end

  def new
	@image = Image.new
  end

  def create
    uploaded_io = params[:image][:filename]
    
    #check MIME type and make sure that the file is an image 	
    unless uploaded_io.content_type.include?("image")
       flash[:error] = "Please upload an image" 
   	   render 'new' and return
    end
    tempfile = uploaded_io.tempfile.path
    image_type = `identify '#{tempfile}' | awk '{print $2}'`.chomp("\n")
    unless ["JPEG","PNG"].include?(image_type)
        flash[:error] = "Please upload a PNG or JPG"    
        render 'new' and return
    end

    ext = File.extname(uploaded_io.original_filename)
   	salt = Time.now.to_i.to_s +  rand(1000).to_s
   	filename = salt + ext

   	@image = Image.new(image_params)
   	@image.url = salt
   	@image.filename = filename
    path = "public/uploads/#{filename}"
	File.open(Rails.root.join('public', 'uploads', filename), 'wb') do |file|
	    file.write(uploaded_io.read)
	end
	
	if @image.save
		redirect_to image_url(@image.url)
	else
        File.delete(path) if File.exist?(path)
        flash[:error] = "Failed"
        redirect_to root_path
	end
	
  end


  def show
  	if params[:image] == nil
  		@image = Image.first
  	else
  		@image = Image.find_by_url(params[:image])
	end
	@points = `python3 app/assets/scripts/contours.py public/uploads/#{@image.filename}`
	puts "points for image id #{@image.id}: #{@points}"
  end

  private
  def image_params
  	params.require(:image).permit(:url, :filename)
  end

end
