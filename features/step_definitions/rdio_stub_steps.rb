Given /^The following songs match the rdio search "([^"]*)":$/ do |query, table|
  results = table.hashes.map do |data|
    song = stub(:name => data["song"],
      :artist => stub(:name => data["artist"]),
      :album =>  stub(:name => data["album"]))
  end

  rdio_api.stub(:search).with(query){
    results
  }
end
