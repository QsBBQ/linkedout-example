require 'sinatra'
require 'sinatra/partial'
require 'better_errors'

require_relative 'config/dotenv'
require_relative 'models'

set :partial_template_engine, :erb

configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = File.expand_path('..', __FILE__)
end

helpers do
  def default_user
    @default_user ||= User.last
  end
end

get "/" do
  @jobs = default_user.jobs
  @skills = default_user.skills

  erb :'resumes/show'
end

get "/resumes/edit" do
  @jobs = default_user.jobs
  @skills = default_user.skills

  erb :'resumes/edit'
end

put "/users/edit" do
  user_attrs = params[:user]

  default_user.update(user_attrs)

  redirect "/"
end

post "/jobs" do
  job_attrs = params[:job]
  job_attrs.merge!({ :user => default_user })

  job = Job.new(job_attrs)
  job.save

  if request.xhr?
    partial :'partials/job', :locals => { :job => job }
  else
    redirect "/"
  end
end

put "/jobs/edit" do
  job_attrs = params[:job]

  job_id = job_attrs.delete("id")

  job = Job.get(job_id)
  job.update(job_attrs)

  redirect "/"
end

post "/skills" do
  skill_attrs = params[:skill]
  skill_attrs.merge!({ :user => default_user })

  skill = Skill.new(skill_attrs)
  skill.save

  if request.xhr? # this will return true when handling an AJAX request
    partial :'partials/skill', :locals => { :skill => skill }
  else
    redirect "/"
  end
end

put "/skills/edit" do
  skill_attrs = params[:skill]

  skill_id = skill_attrs.delete("id")

  skill = Skill.get(skill_id)
  skill.update(skill_attrs)

  redirect "/"
end
