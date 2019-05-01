local unpack = table.unpack
local Pattern = require('../pattern')
docs = Pattern:new({
   name = "docs",
   prefix = "!",
   args = 2,
})
local inspect = require('inspect')

describe('Discord Luabot', function()
   describe('LPEG Patterns', function()
      it('can be the only text in a message', function()
         local str = '!docs'
         local matches = docs:match(str)
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
         assert.are_same(subquery, '')
      end)

      it('can have 1 query', function()
         local str = '!docs lua'
         local matches = docs:match(str)
         local match = matches[1]
         local mentions, queries = unpack(match)
         local query, subquery = unpack(queries)

         assert.are_same(#matches, 1)
         assert.are_same(#mentions, 0)
         assert.is_nil(mentions[1])
         assert.are_same(query, 'lua')
         assert.are_same(subquery, '')
      end)

      it('can have 2 queries', function()
         local str = '!docs lua patterns'
         local matches = docs:match(str)
         local match = matches[1]
         local mentions, queries = unpack(match)
         local query, subquery = unpack(queries)

         assert.are_same(#matches, 1)
         assert.are_same(#mentions, 0)
         assert.is_nil(mentions[1])
         assert.are_same(query, 'lua')
         assert.are_same(subquery, 'patterns')
      end)

      it("won't capture more than 2 queries", function()
         local str = '!docs lua patterns captures'
         local matches = docs:match(str)
         local match = matches[1]
         local mentions, queries = unpack(match)
         local query, subquery, throw_away = unpack(queries)

         assert.are_same(#mentions, 0)
         assert.is_nil(mentions[1])
         assert.are_same(#queries, 2)
         assert.are_same(query, 'lua')
         assert.are_same(subquery, 'patterns')
         assert.is_nil(throw_away)
      end)

      it('can have a mention', function()
         local str = '<@1234512345> !docs'
         local matches = docs:match(str)
         local match = matches[1]
         local mentions, queries = unpack(match)
         local query, subquery = unpack(queries)

         assert.are_same(#matches, 1)
         assert.are_same(#mentions, 1)
         assert.are_same(mentions[1], '<@1234512345>')
         assert.are_same(query, '')
         assert.are_same(subquery, '')
      end)

      it('can have multiple mentions', function()
         local str = '<@1234512345> <@678910678910> !docs'
         local matches = docs:match(str)
         local match = matches[1]
         local mentions, queries = unpack(match)
         local query, subquery = unpack(queries)

         assert.are_same(#matches, 1)
         assert.are_same(#mentions, 2)
         assert.are_same(mentions[1], '<@1234512345>')
         assert.are_same(mentions[2], '<@678910678910>')
         assert.are_same(query, '')
         assert.are_same(subquery, '')
      end)

      it('requires space between mentions and the commmand', function()
         local str = 'hey <@1234512345>!docs lua patterns'
         local matches = docs:match(str)

         assert.are_same(#matches, 0)
      end)

      it('can have multiple matches', function()
         local str = '<@1234512345> !docs lua patterns and <@678910678910> !docs js'
         local matches = docs:match(str)
         local match1, match2 = unpack(matches)

         assert.are_same(#matches, 2)
         -- first match
         local mentions, queries = unpack(match1)
         local query, subquery = unpack(queries)

         assert.are_same(#mentions, 1)
         assert.are_same(mentions[1], '<@1234512345>')
         assert.are_same(query, 'lua')
         assert.are_same(subquery, 'patterns')
         -- second match
         mentions, queries = unpack(match2)
         query, subquery = unpack(queries)

         assert.are_same(#mentions, 1)
         assert.are_same(mentions[1], '<@678910678910>')
         assert.are_same(query, 'js')
         assert.are_same(subquery, '')
      end)

      it('works with multiple matches and ignores malformed calls', function()
         local str = 'hey <@1234512345> !docs lua patterns and <@678910678910> !docs js regexp askjdhaksjhd!docs php lua'
         local matches = docs:match(str)
         local match1, match2, match3 = unpack(matches)

         assert.is_table(matches)
         assert.are_same(#matches, 2)
         -- first match
         local mentions, queries = unpack(match1)
         local query, subquery = unpack(queries)

         assert.is_table(match1)
         assert.are_same(#mentions, 1)
         assert.are_same(mentions[1], '<@1234512345>')
         assert.are_same(query, 'lua')
         assert.are_same(subquery, 'patterns')
         -- second match
         mentions, queries = unpack(match2)
         query, subquery = unpack(queries)

         assert.is_table(match2)
         assert.are_same(#mentions, 1)
         assert.are_same(mentions[1], '<@678910678910>')
         assert.are_same(query, 'js')
         assert.are_same(subquery, 'regexp')
         -- no third match
         assert.is_nil(match3)
      end)

      it('can be can be preceded by unrelated text in a message', function()
         local str = 'hi !docs'
         local matches = docs:match(str)
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
         assert.are_same(subquery, '')
      end)

      it('can be delimited with a semicolon', function()
         local str1 = '!docs; hello world'
         local str2 = '!docs hello; world'
         local str3 = '!docs hello world;'

         -- example 1
         local matches = docs:match(str1)
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
         assert.are_same(subquery, '')

         matches = docs:match(str2)
         match = matches[1]
         mentions, queries = unpack(match)
         query, subquery = unpack(queries)

         assert.is_table(matches)
         assert.are_same(#matches, 1)
         assert.is_table(match)
         assert.is_table(mentions)
         assert.are_same(#mentions, 0)
         assert.is_table(queries)
         assert.are_same(query, 'hello')
         assert.are_same(subquery, '')

         matches = docs:match(str3)
         match = matches[1]
         mentions, queries = unpack(match)
         query, subquery = unpack(queries)

         assert.is_table(matches)
         assert.are_same(#matches, 1)
         assert.is_table(match)
         assert.is_table(mentions)
         assert.are_same(#mentions, 0)
         assert.is_table(queries)
         assert.are_same(query, 'hello')
         assert.are_same(subquery, 'world')
      end)

      it('requires space between unrelated text and command', function()
         local str = 'hello!docs lua patterns captures'
         local matches = docs:match(str)
         local match = matches[1]

         assert.is_table(matches)
         assert.are_same(#matches, 0)
         assert.is_nil(match)
      end)

      it('requires space between command and query', function()
         local str = '!docslua patterns captures'
         local matches = docs:match(str)
         local match = matches[1]

         assert.is_table(matches)
         assert.are_same(#matches, 0)
         assert.is_nil(match)
      end)

      it('ignores command in a codeblock', function()
         local str = '`hello world !docs lua patterns captures`'
         local matches = docs:match(str)
         local match = matches[1]

         assert.is_table(matches)
         assert.are_same(#matches, 0)
         assert.is_nil(match)

         str = '```\nhello world !docs lua patterns captures\n```'
         matches = docs:match(str)
         match = matches[1]

         assert.is_table(matches)
         assert.are_same(#matches, 0)
         assert.is_nil(match)
      end)
   end)
end)
