class UpdateAccessLogsViewToVersion2 < ActiveRecord::Migration[7.0]
  def change
    update_view :access_logs_view, version: 2, revert_to_version: 1
  end
end
