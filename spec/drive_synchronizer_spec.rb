require 'spec_helper'
require './lib/drive_synchronizer.rb'
require 'mocha/test_unit'

describe DiscourseBackupToDrive::DriveSynchronizer do


  let(:b1) { Backup.new('backup1') }
  let(:b2) { Backup.new('backup2') }
  let(:b3) { Backup.new('backup3') }

  before do
    allow(Backup).to receive(:all).and_return([b1, b2, b3])
  end

  describe ".sync" do
    it "syncs itself" do
      should described_class.sync == true
    end
    let(described_class.sync.to_s) do
      GoogleDrive::Session.new(stub_responses: true)
    end
    let(described_class.sync.to_s) do
      Discourse.current_hostname =! nil
    end
  end






  #let ".upload" do
  #  expect {folder_name.add(file)}.to change {folder_name}.to_include(file)
  #end

  #it "creates a session" do
  #  expect(session).to_not be nil
  #end
end
