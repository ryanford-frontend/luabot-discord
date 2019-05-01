local unpack = table.unpack
local help = require('../help').help
local inspect = require('inspect')

describe('Help Command LPEG Patterns', function()
   it('can be the only text in a message', function()
      local str = '!help'
      local matches = help:match(str)
      local match = matches[1]
      local mentions, queries = unpack(match)
      local query, subquery = unpack(queries)

      assert.is_table(matches)
      assert.are_same(#matches, 1)
      assert.is_table(match)
      assert.is_table(mentions)
      assert.are_same(#mentions, 0)
      assert.is_table(queries)
      assert.are_same(query, '')
      assert.is_nil(subquery)
   end)

   it('can have 1 query', function()
      local str = '!help docs'
      local matches = help:match(str)
      local match = matches[1]
      local mentions, queries = unpack(match)
      local query = queries[1]

      assert.are_same(#matches, 1)
      assert.are_same(#mentions, 0)
      assert.is_nil(mentions[1])
      assert.are_same(query, 'docs')
   end)

   it("won't capture more than 1 query", function()
      local str = '!help docs patterns'
      local matches = help:match(str)
      local match = matches[1]
      local mentions, queries = unpack(match)
      local query, throw_away = queries[1]

      assert.are_same(#mentions, 0)
      assert.is_nil(mentions[1])
      assert.are_same(#queries, 1)
      assert.are_same(query, 'docs')
      assert.are_same(subquery, nil)
   end)

   it('can have a mention', function()
      local str = '<@1234512345> !help'
      local matches = help:match(str)
      local match = matches[1]
      local mentions, queries = unpack(match)
      local query = queries[1]

      assert.are_same(#matches, 1)
      assert.are_same(#mentions, 1)
      assert.are_same(mentions[1], '<@1234512345>')
      assert.are_same(query, '')
   end)

   it('can have multiple mentions', function()
      local str = '<@1234512345> <@678910678910> !help'
      local matches = help:match(str)
      local match = matches[1]
      local mentions, queries = unpack(match)
      local query = queries[1]

      assert.are_same(#matches, 1)
      assert.are_same(#mentions, 2)
      assert.are_same(mentions[1], '<@1234512345>')
      assert.are_same(mentions[2], '<@678910678910>')
      assert.are_same(query, '')
   end)

   it('requires space between mentions and the commmand', function()
      local str = 'hey <@1234512345>!help docs'
      local matches = help:match(str)

      assert.are_same(#matches, 0)
   end)

   it('can have multiple matches', function()
      local str = '<@1234512345> !help docs and <@678910678910> !help man'
      local matches = help:match(str)
      local match1, match2 = unpack(matches)

      assert.are_same(#matches, 2)
      -- first match
      local mentions, queries = unpack(match1)
      local query = queries[1]

      assert.are_same(#mentions, 1)
      assert.are_same(mentions[1], '<@1234512345>')
      assert.are_same(query, 'docs')
      -- second match
      mentions, queries = unpack(match2)
      query = queries[1]

      assert.are_same(#mentions, 1)
      assert.are_same(mentions[1], '<@678910678910>')
      assert.are_same(query, 'man')
   end)

   it('works with multiple matches and ignores malformed calls', function()
      local str = '<@1234512345> !help docs and <@678910678910> !help man askjdhaksjhd!help help'
      local matches = help:match(str)
      local match1, match2, match3 = unpack(matches)

      assert.is_table(matches)
      assert.are_same(#matches, 2)
      -- first match
      local mentions, queries = unpack(match1)
      local query = queries[1]

      assert.is_table(match1)
      assert.are_same(#mentions, 1)
      assert.are_same(mentions[1], '<@1234512345>')
      assert.are_same(query, 'docs')
      -- second match
      mentions, queries = unpack(match2)
      query = queries[1]

      assert.is_table(match2)
      assert.are_same(#mentions, 1)
      assert.are_same(mentions[1], '<@678910678910>')
      assert.are_same(query, 'man')
      -- no third match
      assert.is_nil(match3)
   end)

   it('can be can be preceded by unrelated text in a message', function()
      local str = 'hi !help'
      local matches = help:match(str)
      local match = matches[1]
      local mentions, queries = unpack(match)
      local query = queries[1]

      assert.is_table(matches)
      assert.are_same(#matches, 1)
      assert.is_table(match)
      assert.is_table(mentions)
      assert.are_same(#mentions, 0)
      assert.is_table(queries)
      assert.are_same(query, '')
   end)

   it('can be delimited with a semicolon', function()
      local str1 = '!help; hello'
      local str2 = '!help hello;world'

      -- example 1
      local matches = help:match(str1)
      local match = matches[1]
      local mentions, queries = unpack(match)
      local query = queries[1]

      assert.is_table(matches)
      assert.are_same(#matches, 1)
      assert.is_table(match)
      assert.is_table(mentions)
      assert.are_same(#mentions, 0)
      assert.is_table(queries)
      assert.are_same(query, '')

      matches = help:match(str2)
      match = matches[1]
      mentions, queries = unpack(match)
      query = queries[1]

      assert.is_table(matches)
      assert.are_same(#matches, 1)
      assert.is_table(match)
      assert.is_table(mentions)
      assert.are_same(#mentions, 0)
      assert.is_table(queries)
      assert.are_same(query, 'hello')
   end)

   it('requires space between unrelated text and command', function()
      local str = 'hello!help docs patterns captures'
      local matches = help:match(str)
      local match = matches[1]

      assert.is_table(matches)
      assert.are_same(#matches, 0)
      assert.is_nil(match)
   end)

   it('requires space between command and query', function()
      local str = '!helpdocs'
      local matches = help:match(str)
      local match = matches[1]

      assert.is_table(matches)
      assert.are_same(#matches, 0)
      assert.is_nil(match)
   end)

   it('ignores command in a codeblock', function()
      local str = '`hello world !help docs`'
      local matches = help:match(str)
      local match = matches[1]

      assert.is_table(matches)
      assert.are_same(#matches, 0)
      assert.is_nil(match)

      str = '```\nhello world !help docs\n```'
      matches = help:match(str)
      match = matches[1]

      assert.is_table(matches)
      assert.are_same(#matches, 0)
      assert.is_nil(match)
   end)
end)
