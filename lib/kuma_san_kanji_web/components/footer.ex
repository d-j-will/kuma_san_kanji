defmodule KumaSanKanjiWeb.Components.Footer do
  use KumaSanKanjiWeb, :html

  @doc """
  Renders the site footer including attribution required by KanjiVG (CC BY-SA 3.0).
  """
  attr :class, :string, default: ""

  def footer(assigns) do
    ~H"""
    <footer
      class={"border-t border-neutral-200 dark:border-neutral-800 text-xs text-neutral-600 dark:text-neutral-400 fixed bottom-0 left-0 right-0 w-full bg-white dark:bg-neutral-900/95 backdrop-blur supports-[backdrop-filter]:bg-white/80 dark:supports-[backdrop-filter]:bg-neutral-900/80 shadow-sm z-40 #{assigns.class}"}
      role="contentinfo"
      data-footer
    >
      <div class="mx-auto max-w-7xl px-4 py-4 flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
        <p>
          &copy; {Date.utc_today().year} KumaSanKanji ·
          <a href={~p"/credits"} class="underline hover:text-neutral-800 dark:hover:text-neutral-200">
            Credits
          </a>
        </p>
        <p class="leading-snug">
          Kanji stroke order SVGs &copy; KanjiVG project, licensed under <a
            href="https://creativecommons.org/licenses/by-sa/3.0/"
            target="_blank"
            rel="noopener"
            class="underline hover:text-neutral-800 dark:hover:text-neutral-200"
          >CC BY-SA 3.0</a>.
          Attribution: Uses data from <a
            href="http://kanjivg.tagaini.net"
            target="_blank"
            rel="noopener"
            class="underline hover:text-neutral-800 dark:hover:text-neutral-200"
          >KanjiVG</a>.
        </p>
      </div>
    </footer>
    """
  end
end
