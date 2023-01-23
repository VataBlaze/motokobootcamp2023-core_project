import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";

actor {
    
    type Proposal = {
        caller : Principal;
        proposal_number : Nat;
        proposal_text : Text;
        yes_votes : Nat;
        no_votes : Nat;
    };

    stable var proposal_number : Nat = 0;
    stable var proposal_count : Nat = 0;
    stable var proposal_array : [(Nat, Proposal)] = [];
    var proposals = HashMap.fromIter<Nat, Proposal>(proposal_array.vals(), 1, Nat.equal, Hash.hash);
    
    system func postupgrade() {
        proposal_array := [];
    };

    public shared ({ caller }) func submit_proposal(proposal_text : Text) : async {
        #Ok : Proposal;
        #Err : Text;
    } {
        if (proposal_text == "") {
            return #Err("Proposals need substance, you degen!");
        };

        proposal_number += 1;
        proposal_count += 1;

        let new_proposal = {
            caller;
            proposal_number;
            proposal_text;
            yes_votes = 0;
            no_votes = 0;
        };
        proposals.put(proposal_count, new_proposal);
        return #Ok new_proposal;
    };

    public shared ({ caller }) func vote(proposal_id : Nat, yes : Bool) : async {
        #Ok : (Nat, Nat);
        #Err : Text;
    } {

        let current_proposal = proposals.get(proposal_id);

        switch (current_proposal) {
            case (null) {
                return #Err("You're lost! Try a different proposal id.");
            };
            case (?current_proposal) {
                var total_yes_votes = current_proposal.yes_votes;
                var total_no_votes = current_proposal.no_votes;

                if (yes) {
                    total_yes_votes += 1;
                } else {
                    total_no_votes += 1;
                };

                let update_proposal : Proposal = {
                    caller = current_proposal.caller;
                    proposal_number = proposal_number;
                    proposal_text = current_proposal.proposal_text;
                    yes_votes = total_yes_votes;
                    no_votes = total_no_votes;
                };

                proposals.put(proposal_id, update_proposal);
                return #Ok(update_proposal.yes_votes, update_proposal.no_votes);
            };
        };
    };

    public query func get_proposal(id : Nat) : async ?Proposal {
        return proposals.get(id);
    };
    
    public query func get_all_proposals() : async [(Int, Proposal)] {
        var buffer = Buffer.Buffer<(Int, Proposal)>(0);
        for (proposal in proposals.entries()) {
            buffer.add(proposal);
        };
        return Buffer.toArray(buffer);
    };

// If Proposal yes_votes >= 100
//      push 'func modify_text(proposal_text)' to "webpage" canister

    system func preupgrade() {
        proposal_array := Iter.toArray<(Nat, Proposal)>(proposals.entries());
    };
}