defmodule SberbankWeb.LayoutView do
  use SberbankWeb, :view

  def get_flash_if_exist(conn, type, class_name) do
    message = get_flash(conn, type)

    if message do
      content_tag(:p, message, class: "alert #{class_name}", role: "alert")
    end
  end
end
