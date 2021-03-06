defmodule Classlab.Utils.Slugger do
  alias Ecto.Changeset
  @moduledoc"""
  A collection of methods to create beautiful slugs.
  """

  @doc """
  Generates a slug in an ecto changeset.
  """
  def generate_slug(%Changeset{} = changeset, attr, opts \\ []) when is_atom(attr) do
    new_name = Changeset.get_change(changeset, attr)
    new_name =
      if new_name && opts[:random] && Range.range?(opts[:random]) do
        first_random..last_random = opts[:random]
        new_name <> "-" <> Integer.to_string(first_random + :rand.uniform(last_random - first_random))
      else
        new_name
      end

    if new_name do
      changeset
      |> Changeset.put_change(:slug, parameterize(new_name))
    else
      changeset
    end
  end

  @doc """
  Replaces special characters in a string so that it may be used as part of a ‘pretty’ URL.
  """
  def parameterize(str, sep \\ "-") do
    str
    |> transliterate()
    |> String.downcase
    |> turn_unwanted_chars_into_separator(sep)
    |> remove_more_than_one_separator_in_row(sep)
    |> String.trim(sep)
  end

  @doc """
  Replaces non-ASCII characters with an ASCII approximation. Only german supported by now.
  """
  def transliterate(str) do
    str
    |> String.replace("Ü", "Ue")
    |> String.replace("ü", "ue")
    |> String.replace("Ä", "Ae")
    |> String.replace("ä", "ae")
    |> String.replace("Ö", "Oe")
    |> String.replace("ö", "oe")
    |> String.replace("ß", "ss")
  end

  # Private methods
  defp turn_unwanted_chars_into_separator(str, sep) do
    String.replace(str, ~r/[^a-z0-9\-_]+/, sep)
  end

  defp remove_more_than_one_separator_in_row(str, sep) do
    String.replace(str, ~r/#{sep}{2,}/, sep)
  end
end
