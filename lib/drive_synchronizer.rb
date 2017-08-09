module DiscourseBackupToDrive
  class DriveSynchronizer < Synchronizer

    def initialize(backup)
      super(backup)
      @api_key = SiteSetting.discourse_sync_to_googledrive_api_key
      @turned_on = SiteSetting.discourse_sync_to_googledrive_enabled
    end

    def session
      @session ||= GoogleDrive::Session.from_service_account_key(StringIO.new(@api_key))
    end

    def can_sync?
      @turned_on && @api_key.present? && backup.present?
    end

    protected
    def perform_sync
      upload_unique_files
      remove_old_files
    end

    def upload_unique_files
      folder_name = Discourse.current_hostname
      unless session.collection_by_title(folder_name) == nil
        ([backup] - session.collection_by_title(folder_name).files).each do |f|
          if f.present?
            full_path = backup.path
            filename = backup.filename
            file = session.upload_from_file(full_path, filename)
            add_to_folder(file)
            session.root_collection.remove(file)
          end
        end
      end
      full_path = backup.path
      filename = backup.filename
      file = session.upload_from_file(full_path, filename)
      add_to_folder(file)
      session.root_collection.remove(file)
    end

    def add_to_folder(file)
      folder_name = Discourse.current_hostname
      folder = session.collection_by_title(folder_name)
      if folder.present?
        folder.add(file)
      else
        folder = session.root_collection.create_subcollection(folder_name)
        folder.add(file)
      end
    end

    def remove_old_files
      folder_name = Discourse.current_hostname
      unless session.collection_by_title(folder_name) == nil
        google_files = session.collection_by_title(folder_name).files
        sorted = google_files.sort_by {|x| x.created_time}
        keep = sorted.take(SiteSetting.discourse_sync_to_googledrive_quantity)
        trash = google_files - keep
        trash.each { |d| d.delete(true) }
      end
    end
  end
end