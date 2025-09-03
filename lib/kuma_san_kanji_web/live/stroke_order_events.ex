defmodule KumaSanKanjiWeb.StrokeOrderEvents do
  import Phoenix.LiveView, only: [push_event: 3]

  @stroke_events ["stroke_order_restart", "stroke_order_step", "stroke_order_toggle_style"]

  def toggle(socket) do
    Phoenix.LiveView.assign(socket, :show_stroke_order, !socket.assigns.show_stroke_order)
  end

  def stroke_event?(event), do: event in @stroke_events

  def handle(socket, event, %{"kanji" => kanji} = params) when event in @stroke_events do
    mode = Map.get(params, "mode", "brush")
    push_event(socket, event, %{kanji: kanji, mode: mode})
  end
end
