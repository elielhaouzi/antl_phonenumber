defmodule AntlPhonenumber.Ecto.ChangesetTest do
  use AntlPhonenumber.Case
  alias AntlPhonenumber.Ecto.PlusE164

  defmodule Schema do
    use Ecto.Schema

    embedded_schema do
      field(:number, PlusE164)
    end
  end

  describe "validate_country_code/3" do
    test "when the country_code is not the expected one" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(%{number: plus_e164("FR")}, [:number])
        |> AntlPhonenumber.Ecto.Changeset.validate_country_code(:number, "BE")

      refute changeset.valid?
      assert errors_on(changeset).number == ["must be a BE number"]
    end

    test "when the country_code is the expected one" do
      country_code = country_code()

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(%{number: plus_e164(country_code)}, [:number])
        |> AntlPhonenumber.Ecto.Changeset.validate_country_code(:number, country_code)

      assert changeset.valid?
    end
  end

  describe "validate_type/3" do
    test "when the type is not the expected one" do
      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(%{number: plus_e164(country_code(), :fixed_line)}, [
          :number
        ])
        |> AntlPhonenumber.Ecto.Changeset.validate_type(:number, :mobile)

      refute changeset.valid?
      assert errors_on(changeset).number == ["must be a mobile number"]
    end

    test "when the type is the expected one" do
      type = type()

      changeset =
        %Schema{}
        |> Ecto.Changeset.cast(%{number: plus_e164(country_code(), type)}, [:number])
        |> AntlPhonenumber.Ecto.Changeset.validate_type(:number, type)

      assert changeset.valid?
    end
  end

  defp errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end