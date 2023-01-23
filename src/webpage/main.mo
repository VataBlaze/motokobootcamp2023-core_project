import Text "mo:base/Text";
import Http "http";
import Principal "mo:base/Principal";

actor {
public type HttpRequest = Http.HttpRequest;
public type HttpResponse = Http.HttpResponse;

stable var text_canvas : Text = "'ello, Motoko";
stable var DAO_CANISTER : Text = "c7juj-rqaaa-aaaag-qbr5a-cai";


public query func http_request(req : HttpRequest) : async HttpResponse {
    let response = {
      status_code = 200 : Nat16;
      headers = [];
      body = Text.encodeUtf8(text_canvas);
      streaming_strategy = null;
    };
    return response;
  };
/////DAO needs to call this canister/////
public shared ({ caller }) func modify_text(new_text : Text) {
    assert(caller == Principal.fromText(DAO_CANISTER));
    text_canvas := new_text;
  };
}
