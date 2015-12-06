require 'scraperwiki'
require 'net/http'
require 'nokogiri'

(1998..2014).each do |year|
  uri = URI('https://www.ssa.gov/cgi-bin/popularnames.cgi')
  res = Net::HTTP.post_form(uri, year: year, top: 100, number: 'n')
  doc = Nokogiri::HTML(res.body)

  doc.search("table[summary='Popularity for top 100'] tr[align='right']").each do |row|
    cells = row.search("td")
    ScraperWiki.save_sqlite([:name, :year, :gender], {
      gender: 'male',
      year: year,
      rank: cells[0].text.to_i,
      name: cells[1].text.to_s,
      number: cells[2].text.gsub!(',','').to_i
    })

    ScraperWiki.save_sqlite([:name, :year, :gender], {
      gender: 'female',
      year: year,
      rank: cells[0].text.to_i,
      name: cells[3].text.to_s,
      number: cells[4].text.gsub!(',','').to_i
    })
  end
end
