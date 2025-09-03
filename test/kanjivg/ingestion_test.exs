defmodule KumaSanKanji.KanjiVG.IngestionTest do
  use ExUnit.Case, async: true
  alias KumaSanKanji.KanjiVG.Ingestion

  @clean_svg """
  <svg xmlns='http://www.w3.org/2000/svg'><g><path d='M0 0L10 10'/></g></svg>
  """

  @malicious_svg """
  <svg xmlns='http://www.w3.org/2000/svg' onload='alert(1)'>
    <script>alert('x')</script>
    <g>
      <path d='M0 0L10 10' onclick='evil()' xlink:href='http://bad.example/x'/>
    </g>
  </svg>
  """

  test "sanitize_svg keeps allowed structure" do
    assert {:ok, cleaned} = Ingestion.sanitize_svg(@clean_svg)
    assert cleaned =~ "<svg"
    assert cleaned =~ "<path"
  end

  test "sanitize_svg removes scripts, events, external refs" do
    assert {:ok, cleaned} = Ingestion.sanitize_svg(@malicious_svg)
    refute cleaned =~ "script"
    refute cleaned =~ "onload"
    refute cleaned =~ "onclick"
    refute cleaned =~ "http://bad.example"
  end

  test "sanitize_svg invalid input" do
    assert {:error, :invalid_input} = Ingestion.sanitize_svg(nil)
  end
end
