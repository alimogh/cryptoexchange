module Cryptoexchange::Exchanges
  module Bkex
    module Services
      class Market < Cryptoexchange::Services::Market
        class << self
          def supports_individual_ticker_query?
            false
          end
        end

        def fetch
          output = super(ticker_url)
          adapt_all(output)
        end

        def ticker_url
          "#{Cryptoexchange::Exchanges::Bkex::Market::API_URL}/commons/market/tickers"
        end

        def adapt_all(output)
          output['data'].map do |pair|
            base, target = pair['pair'].split('_')
            market_pair  = Cryptoexchange::Models::MarketPair.new(
              base:   base,
              target: target,
              market: Bkex::Market::NAME
            )
            adapt(market_pair, pair)
          end
        end

        def adapt(market_pair, output)
          ticker           = Cryptoexchange::Models::Ticker.new
          ticker.base      = market_pair.base
          ticker.target    = market_pair.target
          ticker.market    = Bkex::Market::NAME
          ticker.last      = NumericHelper.to_d(output['currentPrice'])
          ticker.high      = NumericHelper.to_d(output['maxPrice'])
          ticker.low       = NumericHelper.to_d(output['minPrice'])
          ticker.volume    = NumericHelper.to_d(output['totalAmount'])
          ticker.timestamp = nil
          ticker.payload   = output
          ticker
        end
      end
    end
  end
end
