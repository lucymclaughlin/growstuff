require 'spec_helper'

describe Notification do
  before(:each) do
    @notification = FactoryGirl.create(:notification)
  end

  it "belongs to a post" do
    @notification.post.should be_an_instance_of Post
  end

  it "belongs to a recipient" do
    @notification.recipient.should be_an_instance_of Member
  end

  it "belongs to a sender" do
    @notification.sender.should be_an_instance_of Member
  end

  it "has a scope for unread" do
    Notification.unread.should eq [@notification]
    @n2 = FactoryGirl.create(:notification, :read => true)
    Notification.unread.should eq [@notification]
    @n3 = FactoryGirl.create(:notification, :read => false)
    Notification.unread.should eq [@n3, @notification]
  end

  it "counts unread" do
    @who = @notification.recipient
    @n2 = FactoryGirl.create(:notification, :recipient => @who, :read => false)
    @who.notifications.unread_count.should eq 2
  end

  it "sends email if asked" do
    @notification2 = FactoryGirl.create(:notification)
    @notification2.send_email
    ActionMailer::Base.deliveries.last.to.should == [@notification2.recipient.email]
  end

  it "doesn't send email to people who don't want it" do
    @notification = FactoryGirl.create(:no_email_notification)
    @notification.send_email
    ActionMailer::Base.deliveries.last.to.should_not == [@notification.recipient.email]
  end

  it "sends email on creation" do
    @notification2 = FactoryGirl.create(:notification)
    ActionMailer::Base.deliveries.last.to.should == [@notification2.recipient.email]
  end

  it "replaces missing subjects with (no subject)" do
    @notification = FactoryGirl.create(:notification, :subject => nil)
    @notification.subject.should == "(no subject)"
  end

  it "replaces whitespace-only subjects with (no subject)" do
    @notification = FactoryGirl.create(:notification, :subject => "    ")
    @notification.subject.should == "(no subject)"
  end

end
