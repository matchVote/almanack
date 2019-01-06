defmodule Almanack.DataLoader do
  def run do
    # get us.io data
    # get voteview
    # merge voteview into us.io TERMS
    aggregate(
      Almanack.Sources.USIO.data(),
      Almanack.Sources.VoteView.data()
    )
  end

  def aggregate(_usio, voteview) do
    voteview
  end
end
