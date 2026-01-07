defmodule KumaSanKanji.SRS.Policies do
  @moduledoc """
  Custom policy checks for SRS UserKanjiProgress resource.

  These checks handle user ownership validation and admin bypass logic
  in a way that properly handles the actor context.
  """

  defmodule OwnsProgress do
    @moduledoc """
    Checks if the actor owns the progress record based on user_id.

    For create actions, compares actor.id with the user_id argument.
    For read/update/destroy actions, compares actor.id with the record's user_id.
    """
    use Ash.Policy.SimpleCheck

    def describe(_), do: "owns the progress record"

    def match?(
          %{actor: %{id: actor_id}, action: %{type: :create}, arguments: %{user_id: user_id}},
          _context,
          _opts
        ) do
      actor_id == user_id
    end

    def match?(%{actor: %{id: actor_id}, data: %{user_id: user_id}}, _context, _opts) do
      actor_id == user_id
    end

    def match?(_context, _ash_context, _opts) do
      false
    end
  end

  defmodule IsAdmin do
    @moduledoc """
    Checks if the actor is an admin user.
    """
    use Ash.Policy.SimpleCheck

    def describe(_), do: "is an admin user"

    def match?(%{actor: %{admin: true}}, _context, _opts) do
      true
    end

    def match?(_context, _ash_context, _opts) do
      false
    end
  end

  defmodule IsAuthenticated do
    @moduledoc """
    Checks if an actor is present and authenticated.
    """
    use Ash.Policy.SimpleCheck

    def describe(_), do: "is authenticated"

    def match?(%{actor: actor}, _context, _opts) when not is_nil(actor) do
      true
    end

    def match?(_context, _ash_context, _opts) do
      false
    end
  end
end
