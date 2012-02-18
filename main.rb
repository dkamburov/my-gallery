require "sinatra"
require "data_mapper"
require "dm-paperclip"
require "dm-sqlite-adapter"
require "rubygems"
require "dm-migrations"
require "sinatra/reloader"
require "haml"

APP_ROOT = File.expand_path(File.dirname(__FILE__))

DataMapper.setup(:default, ENV["DATABASE_URL"] || "sqlite3://#{Dir.pwd}/development.db")

class Image

  include DataMapper::Resource
  include Paperclip::Resource
  property :id, Serial
  has_attached_file :file,
                    :url => "/files/:id.:extension",
                    :path => "#{APP_ROOT}/public/files/:id.:extension"
  has n, :comments
end

class Comment

  include DataMapper::Resource
  property :id, Serial
  property :author, String, :required => true
  property :content, String, :required => true
  belongs_to :image
  
end

DataMapper.finalize

def make_paperclip_mash(file_hash)
  
  mash = Mash.new
  mash["tempfile"] = file_hash[:tempfile]
  mash["filename"] = file_hash[:filename]
  mash["content_type"] = file_hash[:type]
  mash["size"] = file_hash[:tempfile].size
  mash

end

get "/upload" do

  haml :upload
  
end

get "/" do

  @pictures = Image.all
  haml :index
  
end

post "/upload" do
  halt "There was no file selected" if params.empty?
  halt "File seems to be emtpy" unless params[:file][:tempfile].size > 0
  @resource = Image.new(:file => make_paperclip_mash(params[:file]))
  halt "There were some errors processing your request..." unless @resource.save
  redirect to "/"
  
end

get "/pic/:id" do
  
  @current = Image.get params[:id]
  haml :show
  
end

post "/:id" do
  
  Image.get(params[:id]).comments.create params[:comment]
  redirect to "/pic/#{params[:id]}"

end

get "/styles.css" do

  content_type "text/css"
  scss :styles
  
end