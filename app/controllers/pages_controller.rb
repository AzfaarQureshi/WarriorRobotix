class PagesController < ApplicationController
  skip_before_action :authenticate_admin!, only: [:home, :contact, :contact_message, :vex, :skills, :other_competitions, :website, :photos, :mentors, :teams, :about_us, :my_attendance, :member_contract]
  before_action :authenticate_member!, only: [:my_attendance]
  def home
    set_meta_tags_for_home
    @show_side_buttons = true
    @latest_posts = Post.where(type: nil, restriction: 0).order(created_at: :DESC).limit(3)
  end

  def website
  end

  def vex
  end

  def my_attendance
    @attendances = current_member.attendances.all.order(:start_at => :asc)
  end

  def skills
  end

  def other_competitions
  end

  def teams
  end

  def about_us
  end

  def member_contract
  end

  def team_editor
    @teams = Team.all
    @members = Array.new
    Member.order(:first_name => :asc).each do |f|
      if f.team_id.nil?
        @members.push(f)
      end
    end
    @removemembers = Member.all
  end

  def contact
    @message = Hash.new
    @show_side_buttons = true
  end

  def contact_message
    @message = params.require(:message).permit(:full_name, :email, :phone_number, :body).to_h.symbolize_keys!
    if verify_recaptcha
      if @message[:full_name].blank?
        flash.now[:alert] = 'Please tell us your name.'
        @message[:full_name] = 'Anonymous'
      elsif @message[:body].blank?
        flash.now[:alert] = 'Message can\'t be blank.'
      else
        @message.merge!(ip: request.remote_ip.to_s, timestamp: Time.zone.now.to_s)
        ContactMailer.contact_us_email(@message).deliver_later
        flash[:notice] =  "Your message has successfully sent to us"
        redirect_to contact_path
        return
      end
    end
    render :contact
  end

  private
  def set_meta_tags_for_home
    set_meta_tags og: {
      title:    'Warrior Robotix',
      type:     'website',
      url:      'http://4659warriors.com',
      description: 'Team 4659 Warrior Robotix is the robotics club of Port Credit Secondary School in Mississauga. We participate in Vex, Skills Ontario and other robotics competitions.',
      image:    [{
        _: 'http://4659warriors.com/assets/pages/home/slider_image_0.jpg',
        type: 'image/jpeg',
        width: 1400,
        height: 700,
      },
      {
        _: 'http://4659warriors.com/assets/pages/home/slider_image_3.jpg',
        type: 'image/jpeg',
        width: 1400,
        height: 700,
      }]
    },  twitter: {
      site: '@WarriorRobotix',
      card: 'summary_large_image',
      description: 'Team 4659 Warrior Robotix is the robotics club of Port Credit Secondary School in Mississauga. We participate in Vex, Skills Ontario and other robotics competitions.',
      image: 'http://4659warriors.com/assets/pages/home/slider_image_0.jpg'
    }, canonical: 'http://4659warriors.com'
  end
end
