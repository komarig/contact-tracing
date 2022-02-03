public with sharing class CTPersonController {
    
    //generate hash out of mobile number
    public static String getToken(String mobileNo){
        Blob value= Blob.valueOf(mobileNo);
        Blob hash=Crypto.generateDigest('ND5', value);

        //get the string value of hash blob
        return EncodingUtil.base64Encode(hash);
    }

}
