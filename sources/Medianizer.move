module Medianizer::Pricer {
    use Std::Signer;
    use Std::Vector;

    struct Round has key, copy, drop {
        round_id: u64,
        prices: vector<PriceUpdate>,
    }

    struct PriceUpdate has store, copy, drop {
        price: u128,
    }

    public(script) fun update_round(account: signer, last_price: u128) 
    acquires Round {
        let account_addr = Signer::address_of(&account);
        if (!exists<Round>(account_addr)) {
            move_to(&account, Round {
                round_id: 0,
                prices: Vector::empty<PriceUpdate>()
            })
        };
        let round = borrow_global_mut<Round>(account_addr);
        Vector::push_back(&mut round.prices, PriceUpdate {
            price: last_price
        });
    }

    public fun get_round_median(account: signer): u128
    acquires Round {
        let account_addr = Signer::address_of(&account);
        assert!(exists<Round>(account_addr), 0);
        let round = borrow_global_mut<Round>(account_addr);
        let prices_length = Vector::length(&round.prices);

        // bubble_sort O(n^2)
        let swapped = true;
        while (swapped) {
            swapped = false;
            let i = 0;
            while (i < (prices_length - 1)) {
                let a = Vector::borrow(&round.prices, i);
                let b = Vector::borrow(&round.prices, i+1);

                if (a.price > b.price) {
                    // swap elements
                    Vector::swap(&mut round.prices, i, i+1);
                    swapped = true;
                };
                i = i + 1;
            };
        };

        // build sorted price array
        let result = Vector::empty<u128>();
        let j = 0;
        while (j < prices_length) {
            let price_holder = Vector::borrow(&round.prices, j);
            Vector::push_back(&mut result, price_holder.price);
            j = j + 1;
        };

        // get median
        let middle_index = prices_length / 2;
        let median_value = Vector::borrow(&round.prices, middle_index).price;
        if (prices_length % 2 == 0) {
            median_value = (
                Vector::borrow(&round.prices, middle_index-1).price + 
                Vector::borrow(&round.prices, middle_index).price
            ) / 2;
        };
        median_value
    }

    #[test(account = @0x1)]
    public(script) fun sender_can_update_price(account: signer) acquires Round {
        update_round(account, 100);
    }
}
