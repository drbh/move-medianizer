#[test_only]
module Medianizer::PricerTests {
    use Std::UnitTest;
    use Std::Vector;

    use Medianizer::Pricer;

    fun get_account(): signer {
        Vector::pop_back(&mut UnitTest::create_signers_for_testing(1))
    }

    #[test]
    public(script) fun sender_can_update_round() {

        let account = get_account();
        Pricer::update_round(account, 101);

        let account = get_account();
        Pricer::update_round(account, 99);

        let account = get_account();
        Pricer::update_round(account, 97);

        let account = get_account();
        Pricer::update_round(account, 120);

        let account = get_account();
        Pricer::update_round(account, 51);

        let account = get_account();
        let median = Pricer::get_round_median(account);

        assert!(
          median == 99,
          0
        );
    }

    #[test]
    public(script) fun sender_can_update_round_even() {

        let account = get_account();
        Pricer::update_round(account, 1000);

        let account = get_account();
        Pricer::update_round(account, 2000);

        let account = get_account();
        Pricer::update_round(account, 3000);

        let account = get_account();
        Pricer::update_round(account, 4000);

        let account = get_account();
        let median = Pricer::get_round_median(account);

        assert!(
          median == 2500,
          0
        );
    }
}
