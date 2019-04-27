local unpack = table.unpack
local docs = require('../docs').docs
local inspect = require('inspect')

describe('Discord Luabot', function()
   describe('LPEG Patterns', function()
      it('can be the first text in a message', function()
         local str = '!docs'
         local matches = docs:match(str)
         local match = matches[1]
         local mentions, queries = unpack(match)
         local query, subquery = unpack(queries)

         assert.are.same(#matches, 1)
         assert.is.same(#mentions, 0)
         assert.are.same(query, '')
         assert.are.same(subquery, '')
      end)

      it('should match calls with 0 queries', function()
         local str = 'hey <@1234512345> !docs'
         local matches = docs:match(str)
         local match = matches[1]
         local mentions, queries = unpack(match)
         local query, subquery = unpack(queries)

         assert.are.same(#matches, 1)
         assert.is.same(#mentions, 1)
         assert.is.same(mentions[1], '<@1234512345>')
         assert.are.same(query, '')
         assert.are.same(subquery, '')
      end)

      it('should capture calls with 1 query', function()
         local str = 'hey <@1234512345> !docs lua'
         local matches = docs:match(str)
         local match = matches[1]
         local mentions, queries = unpack(match)
         local query, subquery = unpack(queries)

         assert.are.same(#matches, 1)
         assert.is.same(#mentions, 1)
         assert.is.same(mentions[1], '<@1234512345>')
         assert.are.same(query, 'lua')
         assert.are.same(subquery, '')
      end)

      it('should capture calls with 2 queries', function()
         local str = 'hey <@1234512345> !docs lua patterns'
         local matches = docs:match(str)
         local match = matches[1]
         local mentions, queries = unpack(match)
         local query, subquery = unpack(queries)

         assert.are.same(#matches, 1)
         assert.is.same(#mentions, 1)
         assert.is.same(mentions[1], '<@1234512345>')
         assert.are.same(query, 'lua')
         assert.are.same(subquery, 'patterns')
      end)

      it('should only capture 2 queries', function()
         local str = 'hey <@1234512345> !docs lua patterns captures'
         local matches = docs:match(str)
         local match = matches[1]
         local mentions, queries = unpack(match)
         local query, subquery, throw_away = unpack(queries)

         assert.is.same(#mentions, 1)
         assert.is.same(mentions[1], '<@1234512345>')
         assert.is.same(#queries, 2)
         assert.are.same(query, 'lua')
         assert.are.same(subquery, 'patterns')
         assert.is.falsy(throw_away)
      end)

      it('should work with no mentions', function()
         local str = 'hey !docs lua patterns'
         local matches = docs:match(str)
         local match = matches[1]
         local mentions, queries = unpack(match)
         local query, subquery = unpack(queries)

         assert.are.same(#matches, 1)
         assert.is.same(#mentions, 0)
         assert.are.same(query, 'lua')
         assert.are.same(subquery, 'patterns')
      end)

      it('should work with multiple mentions', function()
         local str = 'hey <@1234512345> <@678910678910> !docs lua patterns'
         local matches = docs:match(str)
         local match = matches[1]
         local mentions, queries = unpack(match)
         local query, subquery = unpack(queries)

         assert.are.same(#matches, 1)
         assert.is.same(#mentions, 2)
         assert.is.same(mentions[1], '<@1234512345>')
         assert.is.same(mentions[2], '<@678910678910>')
         assert.are.same(query, 'lua')
         assert.are.same(subquery, 'patterns')
      end)

      it('should not match with malformed queries', function()
         local str = 'hey <@1234512345>!docs lua patterns'
         local matches = docs:match(str)
         print(inspect(matches))

         assert.is.falsy(matches)
      end)

      it('should work with multiple matches', function()
         local str = 'hey <@1234512345> !docs lua patterns and <@678910678910> !docs js'
         local matches = docs:match(str)
         local meta = {
            {
               mention = '<@1234512345>',
               query = 'lua',
               subquery = 'patterns',
            },
            {
               mention = '<@678910678910>',
               query = 'js',
               subquery = '',
            },
         }

         for i, match in ipairs(matches) do
            local mentions, queries = unpack(match)
            local query, subquery = unpack(queries)

            assert.are.same(#matches, 2)
            assert.is.same(#mentions, 1)
            assert.is.same(mentions[1], meta[i].mention)
            assert.are.same(query, meta[i].query)
            assert.are.same(subquery, meta[i].subquery)
         end
      end)
   end)
end)
