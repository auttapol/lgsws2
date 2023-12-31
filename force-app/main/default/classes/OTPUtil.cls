// public with sharing class OTPUtil {
//     public OTPUtil() {

//     }
// }

/*    OTPUtil
*     @thank you original : https://github.com/salesforceidentity/OTPUtil
*     @Apex Classes that implement TOTP and HOTP ( Time and HMAC based One-time Passwords per IETF RFC 6238 and 4226 )
*/
public with sharing class OTPUtil {
    /* Encoding Tables */
    private static Map<String, Integer> mapBase32Decode = new Map<String, Integer> {
        'A' => 0, 'E' => 4, 'I' =>  8, 'M' => 12, 'Q' => 16, 'U' => 20, 'Y' => 24, '4' => 28,
        'B' => 1, 'F' => 5, 'J' =>  9, 'N' => 13, 'R' => 17, 'V' => 21, 'Z' => 25, '5' => 29,
        'C' => 2, 'G' => 6, 'K' => 10, 'O' => 14, 'S' => 18, 'W' => 22, '2' => 26, '6' => 30,
        'D' => 3, 'H' => 7, 'L' => 11, 'P' => 15, 'T' => 19, 'X' => 23, '3' => 27, '7' => 31
    };

    private static Map<Integer, String> mapBase32Encode = new Map<Integer, String> {
        0 => 'A', 4 => 'E', 8  => 'I', 12 => 'M', 16 => 'Q', 20 => 'U', 24 => 'Y', 28 => '4',
        1 => 'B', 5 => 'F', 9  => 'J', 13 => 'N', 17 => 'R', 21 => 'V', 25 => 'Z', 29 => '5',
        2 => 'C', 6 => 'G', 10 => 'K', 14 => 'O', 18 => 'S', 22 => 'W', 26 => '2', 30 => '6',
        3 => 'D', 7 => 'H', 11 => 'L', 15 => 'P', 19 => 'T', 23 => 'X', 27 => '3', 31 => '7'
    };

    private static Map<String, Integer> mapBase16Decode = new Map<String, Integer> {
        '0' => 0, '3' => 3, '6' => 6, '9' =>  9, 'c' => 12, 'f' => 15, 'C' => 12, 'E' => 14,
        '1' => 1, '4' => 4, '7' => 7, 'a' => 10, 'd' => 13, 'A' => 10, 'D' => 13, 'F' => 15,
        '2' => 2, '5' => 5, '8' => 8, 'b' => 11, 'e' => 14, 'B' => 11
    };

    private static Map<Integer, String> mapBase16Encode = new Map<Integer, String> {
        0 => '0', 3 => '3', 6 => '6',  9 => '9', 12 => 'C', 15 => 'F',
        1 => '1', 4 => '4', 7 => '7', 10 => 'A', 13 => 'D',
        2 => '2', 5 => '5', 8 => '8', 11 => 'B', 14 => 'E'
    };
    @TestVisible
    private static Blob getCounterRaw(Long count) {
        String hex = '';
        Long index = 0;

        for (integer i = 0; i < 16; i++) {
            index = count & 15L;
            hex = mapBase16Encode.get(index.intValue()) + hex;
            count >>>= 4;
        }
        return EncodingUtil.convertFromHex(hex);
    }

    @TestVisible
    private static Blob getKeyRaw(String base32) {
        return EncodingUtil.convertFromHex(keyB32toB16(Base32));
    }

    @TestVisible
    public static String truncate(String hash, Integer width) {
        Integer offset = 2 * mapBase16Decode.get(hash.substring(hash.length() - 1));
        String  DBC1 = hash.substring(offset, offset + 8);
        Integer OxFO = 0;
        Integer OxOF = 0;
        Integer OxFF = 0;
        for (Integer i = 0; i < 8; i += 2) {
            OxFO   = mapBase16Decode.get(DBC1.substring(i, i + 1));
            OxFO <<= 4;
            OxOF   = mapBase16Decode.get(DBC1.substring(i + 1, i + 2));
            OxFF <<= 8;
            OxFF  += OxFO + OxOF;
        }
        OxFF <<=  1;
        OxFF >>>= 1;
        OxFF = math.mod(OxFF, (math.pow(10, width)).intValue());
        String retVal = String.valueOf(OxFF);
        return retVal.leftPad(width, '0');
    }

    @TestVisible
    public static String generateHmac (Long c, String b32key) {
        return EncodingUtil.convertToHex(
            Crypto.generateMac('hmacSHA1', getCounterRaw(c), getKeyRaw(b32key)));
    }
    public static string generateBase16Key() {
        return EncodingUtil.convertToHex(
            Crypto.generateAesKey(256)
        ).substring(0, 40);
    }

    public static string generateBase32Key () {
        return keyB16toB32(generateBase16Key());
    }

    public static String keyB32toB16(String Base32) {
        String Base16 = '';
        Integer MSBit = 0;
        Integer LSBit = 0;
        for (integer b = 0; b < 32; b += 4 ) {
            for (integer i = 0; i < 5; i++) {
                if (math.mod((i + 1), 5) > 0) {
                    MSBit = mapBase32Decode.get(Base32.substring(b + i, b + i + 1));
                    MSBit = MSBit & (32 - (Integer)math.pow(2, (Double)math.mod((i + 1), 5)));
                    MSBit >>>= math.mod((i + 1), 5);
                } else {
                    MSBit = 0;
                }
                if (math.mod(i, 5) > 0) {
                    LSBit = mapBase32Decode.get(Base32.substring(b + i - 1, b + i));
                    LSBit = LSBit & ((Integer)math.pow(2, (Double)math.mod(i, 5)) - 1);
                    LSBit <<= 4 - math.mod(i, 5);
                } else {
                    LSBit = 0;
                }
                Base16 += mapBase16Encode.get(MSBit + LSBit);
            }
        }
        return Base16;
    }

    public static String keyB16toB32 (String Base16) {
        String Base32 = '';
        Integer MSBit = 0;
        Integer LSBit = 0;
        for (integer b = 0; b < 40; b += 5 ) {
            for (integer i = 0; i < 4; i++) {
                MSBit = mapBase16Decode.get(Base16.substring(b + i, b + i + 1));
                LSBit = mapBase16Decode.get(Base16.substring(b + i + 1, b + i + 2));
                MSBit <<= math.mod(i, 4);
                MSBit = MSBit & 15;
                MSBit <<=  1;
                LSBit >>>= 3 - math.mod(i, 4);
                Base32 += mapBase32Encode.get(MSBit + LSBit);
            }
        }
        return Base32;
    }

    public static string generateOTP(String base32key, Long Counter) {
        String hotp = truncate(generateHmac(Counter, base32key), 6);
        return hotp;
    }

    public static Boolean validateHOTP(String token, String base32key, Long Counter, Long seek) {
        // look ahead, but not beyond the upper bound of yubikey
        if (Counter == 32767L) return false; // upper bound of yubikey
        seek += Counter;
        for (Long i = Counter; i <= seek; i ++) {
            try {
                String hotp = truncate(generateHmac(i, base32key), token.length());
                if (hotp == token) {
                    return true;
                }
            } catch (Exception e) {system.debug('HOTP e1'); return false;}
            if (i >= 32766L) break; // upper bound of yubikey
        }
        return false;
    }

    public static String generateRandomRef(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
        Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
        randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }

}