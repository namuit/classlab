defmodule Classlab.LocaleHelpers do
  alias Calendar

  def l(%Date{} = date, [format: format]) do
    Strftime.strftime!(date, format, :de)
  end

  def l(%DateTime{} = date, [format: format]) do
    date
    # |> Calendar.DateTime.shift_zone!("Europe/Berlin")
    |> Strftime.strftime!(format, :de)
  end

  def l(%Date{} = date) do
    Strftime.strftime!(date, "%d.%m.%Y")
  end

  def l(%DateTime{} = date) do
    date
    # |> Calendar.DateTime.shift_zone!("Europe/Berlin")
    |> Strftime.strftime!("%d.%m.%Y %M:%H")
  end
end
