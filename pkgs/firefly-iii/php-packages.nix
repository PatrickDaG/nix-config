{
  composerEnv,
  fetchurl,
  fetchgit ? null,
  fetchhg ? null,
  fetchsvn ? null,
  noDev ? false,
}: let
  packages = {
    "bacon/bacon-qr-code" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "bacon-bacon-qr-code-8674e51bb65af933a5ffaf1c308a660387c35c22";
        src = fetchurl {
          url = "https://api.github.com/repos/Bacon/BaconQrCode/zipball/8674e51bb65af933a5ffaf1c308a660387c35c22";
          sha256 = "0hb0w6m5rwzghw2im3yqn6ly2kvb3jgrv8jwra1lwd0ik6ckrngl";
        };
      };
    };
    "brick/math" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "brick-math-0ad82ce168c82ba30d1c01ec86116ab52f589478";
        src = fetchurl {
          url = "https://api.github.com/repos/brick/math/zipball/0ad82ce168c82ba30d1c01ec86116ab52f589478";
          sha256 = "04kqy1hqvp4634njjjmhrc2g828d69sk6q3c55bpqnnmsqf154yb";
        };
      };
    };
    "carbonphp/carbon-doctrine-types" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "carbonphp-carbon-doctrine-types-18ba5ddfec8976260ead6e866180bd5d2f71aa1d";
        src = fetchurl {
          url = "https://api.github.com/repos/CarbonPHP/carbon-doctrine-types/zipball/18ba5ddfec8976260ead6e866180bd5d2f71aa1d";
          sha256 = "04vcxjgynvjaz3k1lws1a8cydxiw8blb4iz2xkawq8579rxdiq7v";
        };
      };
    };
    "dasprid/enum" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "dasprid-enum-6faf451159fb8ba4126b925ed2d78acfce0dc016";
        src = fetchurl {
          url = "https://api.github.com/repos/DASPRiD/Enum/zipball/6faf451159fb8ba4126b925ed2d78acfce0dc016";
          sha256 = "1c3c7zdmpd5j1pw9am0k3mj8n17vy6xjhsh2qa7c0azz0f21jk4j";
        };
      };
    };
    "defuse/php-encryption" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "defuse-php-encryption-f53396c2d34225064647a05ca76c1da9d99e5828";
        src = fetchurl {
          url = "https://api.github.com/repos/defuse/php-encryption/zipball/f53396c2d34225064647a05ca76c1da9d99e5828";
          sha256 = "1g4mnnw9nmg1v8zq04d56v5n4m6vr3rsjbqdbny9d2f4c8xd4pqz";
        };
      };
    };
    "dflydev/dot-access-data" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "dflydev-dot-access-data-f41715465d65213d644d3141a6a93081be5d3549";
        src = fetchurl {
          url = "https://api.github.com/repos/dflydev/dflydev-dot-access-data/zipball/f41715465d65213d644d3141a6a93081be5d3549";
          sha256 = "1vgbjrq8qh06r26y5nlxfin4989r3h7dib1jifb2l3cjdn1r5bmj";
        };
      };
    };
    "diglactic/laravel-breadcrumbs" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "diglactic-laravel-breadcrumbs-88e8f01e013e811215770e27b40a74014c28f2c4";
        src = fetchurl {
          url = "https://api.github.com/repos/diglactic/laravel-breadcrumbs/zipball/88e8f01e013e811215770e27b40a74014c28f2c4";
          sha256 = "0syvn89h68ijvx59nb8vq2xxblik3kd0pihr1i10c2qxin28wybq";
        };
      };
    };
    "doctrine/inflector" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "doctrine-inflector-5817d0659c5b50c9b950feb9af7b9668e2c436bc";
        src = fetchurl {
          url = "https://api.github.com/repos/doctrine/inflector/zipball/5817d0659c5b50c9b950feb9af7b9668e2c436bc";
          sha256 = "0yj0f6w0v35d0xdhy4bf7hsjrkjjxsglc879rdciybsk6vz70g96";
        };
      };
    };
    "doctrine/lexer" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "doctrine-lexer-31ad66abc0fc9e1a1f2d9bc6a42668d2fbbcd6dd";
        src = fetchurl {
          url = "https://api.github.com/repos/doctrine/lexer/zipball/31ad66abc0fc9e1a1f2d9bc6a42668d2fbbcd6dd";
          sha256 = "1yaznxpd1d8h3ij262hx946nqvhzsgjmafdgnxbaiarc6nslww25";
        };
      };
    };
    "dragonmantank/cron-expression" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "dragonmantank-cron-expression-adfb1f505deb6384dc8b39804c5065dd3c8c8c0a";
        src = fetchurl {
          url = "https://api.github.com/repos/dragonmantank/cron-expression/zipball/adfb1f505deb6384dc8b39804c5065dd3c8c8c0a";
          sha256 = "1gw2bnsh8ca5plfpyyyz1idnx7zxssg6fbwl7niszck773zrm5ca";
        };
      };
    };
    "egulias/email-validator" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "egulias-email-validator-ebaaf5be6c0286928352e054f2d5125608e5405e";
        src = fetchurl {
          url = "https://api.github.com/repos/egulias/EmailValidator/zipball/ebaaf5be6c0286928352e054f2d5125608e5405e";
          sha256 = "02n4sh0gywqzsl46n9q8hqqgiyva2gj4lxdz9fw4pvhkm1s27wd6";
        };
      };
    };
    "facade/ignition-contracts" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "facade-ignition-contracts-3c921a1cdba35b68a7f0ccffc6dffc1995b18267";
        src = fetchurl {
          url = "https://api.github.com/repos/facade/ignition-contracts/zipball/3c921a1cdba35b68a7f0ccffc6dffc1995b18267";
          sha256 = "1nsjwd1k9q8qmfvh7m50rs42yxzxyq4f56r6dq205gwcmqsjb2j0";
        };
      };
    };
    "filp/whoops" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "filp-whoops-a139776fa3f5985a50b509f2a02ff0f709d2a546";
        src = fetchurl {
          url = "https://api.github.com/repos/filp/whoops/zipball/a139776fa3f5985a50b509f2a02ff0f709d2a546";
          sha256 = "18sfx7s3936q7i4hhn08lr5728c6bqyfqji6kzczjzhlyqkbys10";
        };
      };
    };
    "firebase/php-jwt" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "firebase-php-jwt-a49db6f0a5033aef5143295342f1c95521b075ff";
        src = fetchurl {
          url = "https://api.github.com/repos/firebase/php-jwt/zipball/a49db6f0a5033aef5143295342f1c95521b075ff";
          sha256 = "0rgr90jbp1469pwib3n1yd2by2y3xsc0c5acpzs9iskfcn132swk";
        };
      };
    };
    "fruitcake/php-cors" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "fruitcake-php-cors-3d158f36e7875e2f040f37bc0573956240a5a38b";
        src = fetchurl {
          url = "https://api.github.com/repos/fruitcake/php-cors/zipball/3d158f36e7875e2f040f37bc0573956240a5a38b";
          sha256 = "1pdq0dxrmh4yj48y9azrld10qmz1w3vbb9q81r85fvgl62l2kiww";
        };
      };
    };
    "gdbots/query-parser" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "gdbots-query-parser-d033bb3db7b14cf1c902b0dabe89577cafac2b91";
        src = fetchurl {
          url = "https://api.github.com/repos/gdbots/query-parser-php/zipball/d033bb3db7b14cf1c902b0dabe89577cafac2b91";
          sha256 = "0kbhva8vsk7f577gzjcc2g20yv0lmwzd44h64ys4fn73l17r1r4n";
        };
      };
    };
    "graham-campbell/result-type" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "graham-campbell-result-type-fbd48bce38f73f8a4ec8583362e732e4095e5862";
        src = fetchurl {
          url = "https://api.github.com/repos/GrahamCampbell/Result-Type/zipball/fbd48bce38f73f8a4ec8583362e732e4095e5862";
          sha256 = "1mzahy4df8d45qm716crs45rp5j7k31r0jhkmbrrvqsvapnmj9ip";
        };
      };
    };
    "guzzlehttp/guzzle" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "guzzlehttp-guzzle-41042bc7ab002487b876a0683fc8dce04ddce104";
        src = fetchurl {
          url = "https://api.github.com/repos/guzzle/guzzle/zipball/41042bc7ab002487b876a0683fc8dce04ddce104";
          sha256 = "0awhhka285kk0apv92n0a0yfbihi2ddnx3qr1c7s97asgxfnwxsv";
        };
      };
    };
    "guzzlehttp/promises" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "guzzlehttp-promises-bbff78d96034045e58e13dedd6ad91b5d1253223";
        src = fetchurl {
          url = "https://api.github.com/repos/guzzle/promises/zipball/bbff78d96034045e58e13dedd6ad91b5d1253223";
          sha256 = "1p0bry118c3lichkz8lag37ndvvhbd2nf0k9kzwi8gz1bzf9d45f";
        };
      };
    };
    "guzzlehttp/psr7" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "guzzlehttp-psr7-45b30f99ac27b5ca93cb4831afe16285f57b8221";
        src = fetchurl {
          url = "https://api.github.com/repos/guzzle/psr7/zipball/45b30f99ac27b5ca93cb4831afe16285f57b8221";
          sha256 = "0k60pzfpxd6q1rhr9gbf53j0hm9wj5p5spkc0zfyia4b8f8pgmdm";
        };
      };
    };
    "guzzlehttp/uri-template" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "guzzlehttp-uri-template-ecea8feef63bd4fef1f037ecb288386999ecc11c";
        src = fetchurl {
          url = "https://api.github.com/repos/guzzle/uri-template/zipball/ecea8feef63bd4fef1f037ecb288386999ecc11c";
          sha256 = "0r3cbb2pgsy4nawbylc0nbski2r9dkl335ay5m4i82yglspl9zz4";
        };
      };
    };
    "jc5/google2fa-laravel" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "jc5-google2fa-laravel-0205b0e58b90ee41e6d108d4c26ad9d0f7997baa";
        src = fetchurl {
          url = "https://api.github.com/repos/JC5/google2fa-laravel/zipball/0205b0e58b90ee41e6d108d4c26ad9d0f7997baa";
          sha256 = "01qy0zj9f0rlsfin7ral46ibkpd6xh956084lji14qchxhw7070p";
        };
      };
    };
    "jc5/recovery" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "jc5-recovery-ad69cb910a92e1aeb75fd7eaa65701cc5b0416f3";
        src = fetchurl {
          url = "https://api.github.com/repos/JC5/recovery/zipball/ad69cb910a92e1aeb75fd7eaa65701cc5b0416f3";
          sha256 = "01pw4kbs5pmp5rvn928yk504ykrj4395jpipqn66ksc6m19nyqdj";
        };
      };
    };
    "laravel/framework" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "laravel-framework-1437cea6d2b04cbc83743fbb208e1a01efccd9ec";
        src = fetchurl {
          url = "https://api.github.com/repos/laravel/framework/zipball/1437cea6d2b04cbc83743fbb208e1a01efccd9ec";
          sha256 = "1bbi6w1zyhryn97976cb7r907b9yrrlacjy6mizh84psnq27b6ms";
        };
      };
    };
    "laravel/passport" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "laravel-passport-21099f1aff81706781578a19335d8a4c7c96422a";
        src = fetchurl {
          url = "https://api.github.com/repos/laravel/passport/zipball/21099f1aff81706781578a19335d8a4c7c96422a";
          sha256 = "1zn6krp1j1y2mxy15b5rdjf8vwpg4kyn4hrby1w7n4pgglrdf31r";
        };
      };
    };
    "laravel/prompts" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "laravel-prompts-8ee9f87f7f9eadcbe21e9e72cd4176b2f06cd5b5";
        src = fetchurl {
          url = "https://api.github.com/repos/laravel/prompts/zipball/8ee9f87f7f9eadcbe21e9e72cd4176b2f06cd5b5";
          sha256 = "187pddczxmr778335jxj7cg5rkif5dsjzhqrwn3z7djs3ca64cy7";
        };
      };
    };
    "laravel/sanctum" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "laravel-sanctum-d1de99bf8d31199aaf93881561622489ab91ba58";
        src = fetchurl {
          url = "https://api.github.com/repos/laravel/sanctum/zipball/d1de99bf8d31199aaf93881561622489ab91ba58";
          sha256 = "14zcspjiv697lb9ack6ff1kq90m16dflr59dd3hz0s8magn15b3n";
        };
      };
    };
    "laravel/serializable-closure" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "laravel-serializable-closure-3dbf8a8e914634c48d389c1234552666b3d43754";
        src = fetchurl {
          url = "https://api.github.com/repos/laravel/serializable-closure/zipball/3dbf8a8e914634c48d389c1234552666b3d43754";
          sha256 = "1vvayh1bzbw16xj8ash4flibkgn5afwn64nfwmjdi7lcr48cw65q";
        };
      };
    };
    "laravel/slack-notification-channel" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "laravel-slack-notification-channel-fc8d1873e3db63a480bc57aebb4bf5ec05332d91";
        src = fetchurl {
          url = "https://api.github.com/repos/laravel/slack-notification-channel/zipball/fc8d1873e3db63a480bc57aebb4bf5ec05332d91";
          sha256 = "0h00dpfvipczcfqnj5g8svkpjyjn5w5kigmjnhnal4ljplz076nr";
        };
      };
    };
    "laravel/ui" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "laravel-ui-a3562953123946996a503159199d6742d5534e61";
        src = fetchurl {
          url = "https://api.github.com/repos/laravel/ui/zipball/a3562953123946996a503159199d6742d5534e61";
          sha256 = "0n05mlrnkks0pbxpgh3z9gmbh0fapp1mrj9v0sk3wxlfpdmwbdx4";
        };
      };
    };
    "lcobucci/clock" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "lcobucci-clock-6f28b826ea01306b07980cb8320ab30b966cd715";
        src = fetchurl {
          url = "https://api.github.com/repos/lcobucci/clock/zipball/6f28b826ea01306b07980cb8320ab30b966cd715";
          sha256 = "0h71b19mjn0n0gr512482ryjjpmxc3x546pjbyl21d4qi6b4ixrg";
        };
      };
    };
    "lcobucci/jwt" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "lcobucci-jwt-0ba88aed12c04bd2ed9924f500673f32b67a6211";
        src = fetchurl {
          url = "https://api.github.com/repos/lcobucci/jwt/zipball/0ba88aed12c04bd2ed9924f500673f32b67a6211";
          sha256 = "0icvs7glzsb3j63fsa0j6d210hj5vaw3n6crzjdczdhiiz71hs0r";
        };
      };
    };
    "league/commonmark" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "league-commonmark-91c24291965bd6d7c46c46a12ba7492f83b1cadf";
        src = fetchurl {
          url = "https://api.github.com/repos/thephpleague/commonmark/zipball/91c24291965bd6d7c46c46a12ba7492f83b1cadf";
          sha256 = "1i7yqcp4hdzz1k6qga96jwp9qpw7dxlfr5miw48zyym60ndk9n02";
        };
      };
    };
    "league/config" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "league-config-754b3604fb2984c71f4af4a9cbe7b57f346ec1f3";
        src = fetchurl {
          url = "https://api.github.com/repos/thephpleague/config/zipball/754b3604fb2984c71f4af4a9cbe7b57f346ec1f3";
          sha256 = "0yjb85cd0qa0mra995863dij2hmcwk9x124vs8lrwiylb0l3mn8s";
        };
      };
    };
    "league/csv" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "league-csv-fa7e2441c0bc9b2360f4314fd6c954f7ff40d435";
        src = fetchurl {
          url = "https://api.github.com/repos/thephpleague/csv/zipball/fa7e2441c0bc9b2360f4314fd6c954f7ff40d435";
          sha256 = "0f9qgmaqj7ndfdh08jxh6474friyqk80nbz5bf7dnv3hwfp9wxfm";
        };
      };
    };
    "league/event" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "league-event-d2cc124cf9a3fab2bb4ff963307f60361ce4d119";
        src = fetchurl {
          url = "https://api.github.com/repos/thephpleague/event/zipball/d2cc124cf9a3fab2bb4ff963307f60361ce4d119";
          sha256 = "1fc8aj0mpbrnh3b93gn8pypix28nf2gfvi403kfl7ibh5iz6ds5l";
        };
      };
    };
    "league/flysystem" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "league-flysystem-072735c56cc0da00e10716dd90d5a7f7b40b36be";
        src = fetchurl {
          url = "https://api.github.com/repos/thephpleague/flysystem/zipball/072735c56cc0da00e10716dd90d5a7f7b40b36be";
          sha256 = "1q9v90fc1g2ric6jgld6rsxmh1rw78smvjx3l4c9jhamzd8m2q41";
        };
      };
    };
    "league/flysystem-local" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "league-flysystem-local-61a6a90d6e999e4ddd9ce5adb356de0939060b92";
        src = fetchurl {
          url = "https://api.github.com/repos/thephpleague/flysystem-local/zipball/61a6a90d6e999e4ddd9ce5adb356de0939060b92";
          sha256 = "0mkcqhmxgq5pwbfzqc26z06384v7plva5s71pqyqdaayb1hlyg1f";
        };
      };
    };
    "league/fractal" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "league-fractal-8b9d39b67624db9195c06f9c1ffd0355151eaf62";
        src = fetchurl {
          url = "https://api.github.com/repos/thephpleague/fractal/zipball/8b9d39b67624db9195c06f9c1ffd0355151eaf62";
          sha256 = "02zk3hpwbxrxixw54ar2gflsy762fqkvbdg3wy3d60rvyscpha7l";
        };
      };
    };
    "league/mime-type-detection" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "league-mime-type-detection-ce0f4d1e8a6f4eb0ddff33f57c69c50fd09f4301";
        src = fetchurl {
          url = "https://api.github.com/repos/thephpleague/mime-type-detection/zipball/ce0f4d1e8a6f4eb0ddff33f57c69c50fd09f4301";
          sha256 = "1yvjnqb6wv6kxfs21qw31yqcb653dz2xw9g646y2g9via33fxvpd";
        };
      };
    };
    "league/oauth2-server" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "league-oauth2-server-ab7714d073844497fd222d5d0a217629089936bc";
        src = fetchurl {
          url = "https://api.github.com/repos/thephpleague/oauth2-server/zipball/ab7714d073844497fd222d5d0a217629089936bc";
          sha256 = "1p4lvibdfi458bv778qzbah3b1lkhdvd9hiws040ky8jizfs6c2g";
        };
      };
    };
    "league/uri" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "league-uri-bedb6e55eff0c933668addaa7efa1e1f2c417cc4";
        src = fetchurl {
          url = "https://api.github.com/repos/thephpleague/uri/zipball/bedb6e55eff0c933668addaa7efa1e1f2c417cc4";
          sha256 = "1yjz635dyxx7sm80if80k6bpmwx4qb41l27p2xf34k4yln8jz1y3";
        };
      };
    };
    "league/uri-interfaces" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "league-uri-interfaces-8d43ef5c841032c87e2de015972c06f3865ef718";
        src = fetchurl {
          url = "https://api.github.com/repos/thephpleague/uri-interfaces/zipball/8d43ef5c841032c87e2de015972c06f3865ef718";
          sha256 = "0yzdl7iajgfxwr3zq87hsk93hgsh16kgs2h14kr5g0wy3761pmrw";
        };
      };
    };
    "monolog/monolog" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "monolog-monolog-c915e2634718dbc8a4a15c61b0e62e7a44e14448";
        src = fetchurl {
          url = "https://api.github.com/repos/Seldaek/monolog/zipball/c915e2634718dbc8a4a15c61b0e62e7a44e14448";
          sha256 = "1sqqjdg75vc578zrm6xklmk9928l4dc7csjvlpln331b8rnai8hs";
        };
      };
    };
    "nesbot/carbon" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "nesbot-carbon-4d599a6e2351d6b6bf21737accdfe1a4ce3fdbb1";
        src = fetchurl {
          url = "https://api.github.com/repos/briannesbitt/Carbon/zipball/4d599a6e2351d6b6bf21737accdfe1a4ce3fdbb1";
          sha256 = "0y4ib4q4a5cyaal41fcagkkh2fnyk286pr32lnxl43011ybi4g7h";
        };
      };
    };
    "nette/schema" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "nette-schema-a6d3a6d1f545f01ef38e60f375d1cf1f4de98188";
        src = fetchurl {
          url = "https://api.github.com/repos/nette/schema/zipball/a6d3a6d1f545f01ef38e60f375d1cf1f4de98188";
          sha256 = "0byhgs7jv0kybv0x3xycvi0x2gh7009a3dfgs02yqzzjbbwvrzgz";
        };
      };
    };
    "nette/utils" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "nette-utils-d3ad0aa3b9f934602cb3e3902ebccf10be34d218";
        src = fetchurl {
          url = "https://api.github.com/repos/nette/utils/zipball/d3ad0aa3b9f934602cb3e3902ebccf10be34d218";
          sha256 = "11df93i9xkwkfq33hqf2x562a36sibzpc6rkbblz2r10mna6qw6q";
        };
      };
    };
    "nunomaduro/collision" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "nunomaduro-collision-13e5d538b95a744d85f447a321ce10adb28e9af9";
        src = fetchurl {
          url = "https://api.github.com/repos/nunomaduro/collision/zipball/13e5d538b95a744d85f447a321ce10adb28e9af9";
          sha256 = "1bfazfmkzac01ccnf03wy91x53virpr6ir961nm2c4p9n2872pkx";
        };
      };
    };
    "nunomaduro/termwind" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "nunomaduro-termwind-58c4c58cf23df7f498daeb97092e34f5259feb6a";
        src = fetchurl {
          url = "https://api.github.com/repos/nunomaduro/termwind/zipball/58c4c58cf23df7f498daeb97092e34f5259feb6a";
          sha256 = "17w8h281qdyagf8pv7zny9jy7zf0y7jmm7shrzv05a3ghwknirq2";
        };
      };
    };
    "nyholm/psr7" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "nyholm-psr7-aa5fc277a4f5508013d571341ade0c3886d4d00e";
        src = fetchurl {
          url = "https://api.github.com/repos/Nyholm/psr7/zipball/aa5fc277a4f5508013d571341ade0c3886d4d00e";
          sha256 = "00r9sy7ncrjdc71kqis4vc6q1ksbh97g3fhf97gf5jg9j6pq27lg";
        };
      };
    };
    "paragonie/constant_time_encoding" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "paragonie-constant_time_encoding-58c3f47f650c94ec05a151692652a868995d2938";
        src = fetchurl {
          url = "https://api.github.com/repos/paragonie/constant_time_encoding/zipball/58c3f47f650c94ec05a151692652a868995d2938";
          sha256 = "0i9km0lzvc7df9758fm1p3y0679pzvr5m9x3mrz0d2hxlppsm764";
        };
      };
    };
    "paragonie/random_compat" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "paragonie-random_compat-996434e5492cb4c3edcb9168db6fbb1359ef965a";
        src = fetchurl {
          url = "https://api.github.com/repos/paragonie/random_compat/zipball/996434e5492cb4c3edcb9168db6fbb1359ef965a";
          sha256 = "0ky7lal59dihf969r1k3pb96ql8zzdc5062jdbg69j6rj0scgkyx";
        };
      };
    };
    "phpoption/phpoption" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpoption-phpoption-80735db690fe4fc5c76dfa7f9b770634285fa820";
        src = fetchurl {
          url = "https://api.github.com/repos/schmittjoh/php-option/zipball/80735db690fe4fc5c76dfa7f9b770634285fa820";
          sha256 = "1f9hzyjnam157lb7iw9r8f5cnjjsiqam9mnkpqmba73g1668xn9s";
        };
      };
    };
    "phpseclib/phpseclib" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpseclib-phpseclib-cfa2013d0f68c062055180dd4328cc8b9d1f30b8";
        src = fetchurl {
          url = "https://api.github.com/repos/phpseclib/phpseclib/zipball/cfa2013d0f68c062055180dd4328cc8b9d1f30b8";
          sha256 = "1wgzy4fbj565czpn9xasr8lnd9ilh1x3bsalrpx5bskvqr4zspgj";
        };
      };
    };
    "pragmarx/google2fa" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "pragmarx-google2fa-80c3d801b31fe165f8fe99ea085e0a37834e1be3";
        src = fetchurl {
          url = "https://api.github.com/repos/antonioribeiro/google2fa/zipball/80c3d801b31fe165f8fe99ea085e0a37834e1be3";
          sha256 = "0qfjgkl02ifc0zicv3d5d6zs8mwpq68bg211jy3psgghnqpxyhlm";
        };
      };
    };
    "pragmarx/google2fa-qrcode" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "pragmarx-google2fa-qrcode-fd5ff0531a48b193a659309cc5fb882c14dbd03f";
        src = fetchurl {
          url = "https://api.github.com/repos/antonioribeiro/google2fa-qrcode/zipball/fd5ff0531a48b193a659309cc5fb882c14dbd03f";
          sha256 = "1csa15v68bznrz3262xjcdgcgw0lg8fwb6fhrbms2mnylhq4s35g";
        };
      };
    };
    "pragmarx/random" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "pragmarx-random-daf08a189c5d2d40d1a827db46364d3a741a51b7";
        src = fetchurl {
          url = "https://api.github.com/repos/antonioribeiro/random/zipball/daf08a189c5d2d40d1a827db46364d3a741a51b7";
          sha256 = "05szknpz05jj6jan39mgbmkl0m23clcaaiky649d6z9whbcd18wh";
        };
      };
    };
    "predis/predis" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "predis-predis-b1d3255ed9ad4d7254f9f9bba386c99f4bb983d1";
        src = fetchurl {
          url = "https://api.github.com/repos/predis/predis/zipball/b1d3255ed9ad4d7254f9f9bba386c99f4bb983d1";
          sha256 = "0pylca7in1fm6vyrfdp12pqamp7y09cr5mc8hyr1m22r9f6m82l9";
        };
      };
    };
    "psr/cache" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "psr-cache-aa5030cfa5405eccfdcb1083ce040c2cb8d253bf";
        src = fetchurl {
          url = "https://api.github.com/repos/php-fig/cache/zipball/aa5030cfa5405eccfdcb1083ce040c2cb8d253bf";
          sha256 = "07rnyjwb445sfj30v5ny3gfsgc1m7j7cyvwjgs2cm9slns1k1ml8";
        };
      };
    };
    "psr/clock" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "psr-clock-e41a24703d4560fd0acb709162f73b8adfc3aa0d";
        src = fetchurl {
          url = "https://api.github.com/repos/php-fig/clock/zipball/e41a24703d4560fd0acb709162f73b8adfc3aa0d";
          sha256 = "0wz5b8hgkxn3jg88cb3901hj71axsj0fil6pwl413igghch6i8kj";
        };
      };
    };
    "psr/container" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "psr-container-c71ecc56dfe541dbd90c5360474fbc405f8d5963";
        src = fetchurl {
          url = "https://api.github.com/repos/php-fig/container/zipball/c71ecc56dfe541dbd90c5360474fbc405f8d5963";
          sha256 = "1mvan38yb65hwk68hl0p7jymwzr4zfnaxmwjbw7nj3rsknvga49i";
        };
      };
    };
    "psr/event-dispatcher" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "psr-event-dispatcher-dbefd12671e8a14ec7f180cab83036ed26714bb0";
        src = fetchurl {
          url = "https://api.github.com/repos/php-fig/event-dispatcher/zipball/dbefd12671e8a14ec7f180cab83036ed26714bb0";
          sha256 = "05nicsd9lwl467bsv4sn44fjnnvqvzj1xqw2mmz9bac9zm66fsjd";
        };
      };
    };
    "psr/http-client" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "psr-http-client-bb5906edc1c324c9a05aa0873d40117941e5fa90";
        src = fetchurl {
          url = "https://api.github.com/repos/php-fig/http-client/zipball/bb5906edc1c324c9a05aa0873d40117941e5fa90";
          sha256 = "1dfyjqj1bs2n2zddk8402v6rjq93fq26hwr0rjh53m11wy1wagsx";
        };
      };
    };
    "psr/http-factory" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "psr-http-factory-e616d01114759c4c489f93b099585439f795fe35";
        src = fetchurl {
          url = "https://api.github.com/repos/php-fig/http-factory/zipball/e616d01114759c4c489f93b099585439f795fe35";
          sha256 = "1vzimn3h01lfz0jx0lh3cy9whr3kdh103m1fw07qric4pnnz5kx8";
        };
      };
    };
    "psr/http-message" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "psr-http-message-402d35bcb92c70c026d1a6a9883f06b2ead23d71";
        src = fetchurl {
          url = "https://api.github.com/repos/php-fig/http-message/zipball/402d35bcb92c70c026d1a6a9883f06b2ead23d71";
          sha256 = "13cnlzrh344n00sgkrp5cgbkr8dznd99c3jfnpl0wg1fdv1x4qfm";
        };
      };
    };
    "psr/log" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "psr-log-fe5ea303b0887d5caefd3d431c3e61ad47037001";
        src = fetchurl {
          url = "https://api.github.com/repos/php-fig/log/zipball/fe5ea303b0887d5caefd3d431c3e61ad47037001";
          sha256 = "0a0rwg38vdkmal3nwsgx58z06qkfl85w2yvhbgwg45anr0b3bhmv";
        };
      };
    };
    "psr/simple-cache" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "psr-simple-cache-764e0b3939f5ca87cb904f570ef9be2d78a07865";
        src = fetchurl {
          url = "https://api.github.com/repos/php-fig/simple-cache/zipball/764e0b3939f5ca87cb904f570ef9be2d78a07865";
          sha256 = "0hgcanvd9gqwkaaaq41lh8fsfdraxmp2n611lvqv69jwm1iy76g8";
        };
      };
    };
    "ralouphie/getallheaders" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "ralouphie-getallheaders-120b605dfeb996808c31b6477290a714d356e822";
        src = fetchurl {
          url = "https://api.github.com/repos/ralouphie/getallheaders/zipball/120b605dfeb996808c31b6477290a714d356e822";
          sha256 = "1bv7ndkkankrqlr2b4kw7qp3fl0dxi6bp26bnim6dnlhavd6a0gg";
        };
      };
    };
    "ramsey/collection" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "ramsey-collection-a4b48764bfbb8f3a6a4d1aeb1a35bb5e9ecac4a5";
        src = fetchurl {
          url = "https://api.github.com/repos/ramsey/collection/zipball/a4b48764bfbb8f3a6a4d1aeb1a35bb5e9ecac4a5";
          sha256 = "0y5s9rbs023sw94yzvxr8fn9rr7xw03f08zmc9n9jl49zlr5s52p";
        };
      };
    };
    "ramsey/uuid" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "ramsey-uuid-5f0df49ae5ad6efb7afa69e6bfab4e5b1e080d8e";
        src = fetchurl {
          url = "https://api.github.com/repos/ramsey/uuid/zipball/5f0df49ae5ad6efb7afa69e6bfab4e5b1e080d8e";
          sha256 = "0gnpj6jsmwr5azxq8ymp0zpscgxcwld7ps2q9rbkbndr9f9cpkkg";
        };
      };
    };
    "rcrowe/twigbridge" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "rcrowe-twigbridge-6bf5a8fa48eb5d45de0bd5027936796947acfcbc";
        src = fetchurl {
          url = "https://api.github.com/repos/rcrowe/TwigBridge/zipball/6bf5a8fa48eb5d45de0bd5027936796947acfcbc";
          sha256 = "0bvhj0xq2v4hkr50w1kwl15cml5xhl703yry7znkbyd4dglbc090";
        };
      };
    };
    "spatie/backtrace" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "spatie-backtrace-483f76a82964a0431aa836b6ed0edde0c248e3ab";
        src = fetchurl {
          url = "https://api.github.com/repos/spatie/backtrace/zipball/483f76a82964a0431aa836b6ed0edde0c248e3ab";
          sha256 = "1mb7fk0phc065iz0b1s6zf0lbn5nz6r2x0g6z650rwdkc015vh9n";
        };
      };
    };
    "spatie/flare-client-php" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "spatie-flare-client-php-17082e780752d346c2db12ef5d6bee8e835e399c";
        src = fetchurl {
          url = "https://api.github.com/repos/spatie/flare-client-php/zipball/17082e780752d346c2db12ef5d6bee8e835e399c";
          sha256 = "0s0rmy73wxs38bnl4gxk02b3g68d5nc56svxln9xm2p6xc7l34s0";
        };
      };
    };
    "spatie/ignition" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "spatie-ignition-889bf1dfa59e161590f677728b47bf4a6893983b";
        src = fetchurl {
          url = "https://api.github.com/repos/spatie/ignition/zipball/889bf1dfa59e161590f677728b47bf4a6893983b";
          sha256 = "1svphpnaby267mjzdrczkyvrv7m4x050pv48zbpjqklzx2cj6s8l";
        };
      };
    };
    "spatie/laravel-html" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "spatie-laravel-html-df15763c190954ee46a74e0bf5b4b5bbf2e1f170";
        src = fetchurl {
          url = "https://api.github.com/repos/spatie/laravel-html/zipball/df15763c190954ee46a74e0bf5b4b5bbf2e1f170";
          sha256 = "1wf4pkmzb6llrcxs3ds4w1yklisciljqc9dpzjpgc8d8hkc0a72p";
        };
      };
    };
    "spatie/laravel-ignition" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "spatie-laravel-ignition-e23f4e8ce6644dc3d68b9d8a0aed3beaca0d6ada";
        src = fetchurl {
          url = "https://api.github.com/repos/spatie/laravel-ignition/zipball/e23f4e8ce6644dc3d68b9d8a0aed3beaca0d6ada";
          sha256 = "0s8vplcxl86vd3l1agbssn46zpvrakwg5mjlcrjg386cdyphb2yj";
        };
      };
    };
    "spatie/period" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "spatie-period-85fbbea7b24fdff0c924aeed5b109be93c025850";
        src = fetchurl {
          url = "https://api.github.com/repos/spatie/period/zipball/85fbbea7b24fdff0c924aeed5b109be93c025850";
          sha256 = "0m2wga4ql43mq0vkzxr24yf6mm7aiqm4brxpi0i58ja7578mc6hd";
        };
      };
    };
    "symfony/cache" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-cache-fc822951dd360a593224bb2cef90a087d0dff60f";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/cache/zipball/fc822951dd360a593224bb2cef90a087d0dff60f";
          sha256 = "0pmsls362m6a9s46nx1qsr6zpyldvbbx1ni5mgva9ppxmacpcgil";
        };
      };
    };
    "symfony/cache-contracts" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-cache-contracts-1d74b127da04ffa87aa940abe15446fa89653778";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/cache-contracts/zipball/1d74b127da04ffa87aa940abe15446fa89653778";
          sha256 = "0n8zxm1qqlgzhk3f23s2bjll6il7qkszh1kr9p7hx895vp0rnk9c";
        };
      };
    };
    "symfony/clock" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-clock-8b9d08887353d627d5f6c3bf3373b398b49051c2";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/clock/zipball/8b9d08887353d627d5f6c3bf3373b398b49051c2";
          sha256 = "0qh9yz5jrqv63i2lwg0zz1qhsjpci6av0hms3x2jvnpp09fy2fa1";
        };
      };
    };
    "symfony/console" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-console-6b099f3306f7c9c2d2786ed736d0026b2903205f";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/console/zipball/6b099f3306f7c9c2d2786ed736d0026b2903205f";
          sha256 = "1sx87bw3zfmjcv0ajq8idfj27f5x0xma4v6lwm7iji4pwmfyw6rk";
        };
      };
    };
    "symfony/css-selector" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-css-selector-ec60a4edf94e63b0556b6a0888548bb400a3a3be";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/css-selector/zipball/ec60a4edf94e63b0556b6a0888548bb400a3a3be";
          sha256 = "09lam6s1826pw4gkz4qp9jvsvq7g968sr4g271abq966jwkkvirs";
        };
      };
    };
    "symfony/deprecation-contracts" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-deprecation-contracts-7c3aff79d10325257a001fcf92d991f24fc967cf";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/deprecation-contracts/zipball/7c3aff79d10325257a001fcf92d991f24fc967cf";
          sha256 = "0p0c2942wjq1bb06y9i8gw6qqj7sin5v5xwsvl0zdgspbr7jk1m9";
        };
      };
    };
    "symfony/error-handler" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-error-handler-677b24759decff69e65b1e9d1471d90f95ced880";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/error-handler/zipball/677b24759decff69e65b1e9d1471d90f95ced880";
          sha256 = "15q4nhj7c72582q3qx75xkknkjc4klgmf1y6gvcvrapsbzsj5f5g";
        };
      };
    };
    "symfony/event-dispatcher" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-event-dispatcher-834c28d533dd0636f910909d01b9ff45cc094b5e";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/event-dispatcher/zipball/834c28d533dd0636f910909d01b9ff45cc094b5e";
          sha256 = "1ls1nq51qjhp0vqsc3ypy2n06iqc9dxfs9wbycnv575ajiabrm7r";
        };
      };
    };
    "symfony/event-dispatcher-contracts" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-event-dispatcher-contracts-a76aed96a42d2b521153fb382d418e30d18b59df";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/event-dispatcher-contracts/zipball/a76aed96a42d2b521153fb382d418e30d18b59df";
          sha256 = "1w49s1q6xhcmkgd3xkyjggiwys0wvyny0p3018anvdi0k86zg678";
        };
      };
    };
    "symfony/expression-language" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-expression-language-0877c599cb260c9614f9229c0a2090d6919fd621";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/expression-language/zipball/0877c599cb260c9614f9229c0a2090d6919fd621";
          sha256 = "1m4qn0qdna8rbjgvh66zzac9sdrxvykki03giwmrrgixjhd9xcfk";
        };
      };
    };
    "symfony/finder" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-finder-6e5688d69f7cfc4ed4a511e96007e06c2d34ce56";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/finder/zipball/6e5688d69f7cfc4ed4a511e96007e06c2d34ce56";
          sha256 = "1iyfdwx93xwkm4i4vgzlb9d174a8x5asgh9mwanxpplx5xh5m47i";
        };
      };
    };
    "symfony/http-client" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-http-client-425f462a59d8030703ee04a9e1c666575ed5db3b";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/http-client/zipball/425f462a59d8030703ee04a9e1c666575ed5db3b";
          sha256 = "05psybjl3pdrc4k1safpn815x3f95s58316jz99430cc7q8ai86w";
        };
      };
    };
    "symfony/http-client-contracts" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-http-client-contracts-1ee70e699b41909c209a0c930f11034b93578654";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/http-client-contracts/zipball/1ee70e699b41909c209a0c930f11034b93578654";
          sha256 = "181m2alsmj9v8wkzn210g6v41nl2fx519f674p7r9q0m22ivk2ca";
        };
      };
    };
    "symfony/http-foundation" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-http-foundation-439fdfdd344943254b1ef6278613e79040548045";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/http-foundation/zipball/439fdfdd344943254b1ef6278613e79040548045";
          sha256 = "1hg6br8pp8vf3465mawa9bvmr7c09hs5j0kwrq6slgdlvgy4yax4";
        };
      };
    };
    "symfony/http-kernel" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-http-kernel-37c24ca28f65e3121a68f3dd4daeb36fb1fa2a72";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/http-kernel/zipball/37c24ca28f65e3121a68f3dd4daeb36fb1fa2a72";
          sha256 = "0cvjrcjnzfi88hblnq4q7w8wklrxmrqppm4vpr8d7zayaw0j5a0v";
        };
      };
    };
    "symfony/mailer" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-mailer-72e16d87bf50a3ce195b9470c06bb9d7b816ea85";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/mailer/zipball/72e16d87bf50a3ce195b9470c06bb9d7b816ea85";
          sha256 = "1p3kzqzn4dyp4cz4n25z42mfphzzmza27w31fi01k92hdfzrnbyr";
        };
      };
    };
    "symfony/mailgun-mailer" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-mailgun-mailer-96df0d3815dc72367ecc38c4a82d8021f8bddd4e";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/mailgun-mailer/zipball/96df0d3815dc72367ecc38c4a82d8021f8bddd4e";
          sha256 = "1s6mj852svpnqrkw7s2q2m9lysf1j9ys6k8ag9hdgp4wh0s2pxd2";
        };
      };
    };
    "symfony/mime" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-mime-c1ffe24ba6fdc3e3f0f3fcb93519103b326a3716";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/mime/zipball/c1ffe24ba6fdc3e3f0f3fcb93519103b326a3716";
          sha256 = "1yyhbscrbvnab3qs3j3pw9f332p5j22ybd0sqayzr1vflqa50yld";
        };
      };
    };
    "symfony/polyfill-ctype" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-ctype-ef4d7e442ca910c4764bce785146269b30cb5fc4";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-ctype/zipball/ef4d7e442ca910c4764bce785146269b30cb5fc4";
          sha256 = "16wr6dp9yr4wks11d1qjyzpc343ri2nr7q7fmrnp3jhmp949rppy";
        };
      };
    };
    "symfony/polyfill-intl-grapheme" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-intl-grapheme-32a9da87d7b3245e09ac426c83d334ae9f06f80f";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-intl-grapheme/zipball/32a9da87d7b3245e09ac426c83d334ae9f06f80f";
          sha256 = "03wk7yxavld4jnvavy7m2d3xxn5h4938wypgwjkblgx8n7s93jiq";
        };
      };
    };
    "symfony/polyfill-intl-idn" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-intl-idn-a287ed7475f85bf6f61890146edbc932c0fff919";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-intl-idn/zipball/a287ed7475f85bf6f61890146edbc932c0fff919";
          sha256 = "14x9hv01fn5dmpkm7480lgzhz4lqdi3w1hlkh3sjpb6ic87k0wc1";
        };
      };
    };
    "symfony/polyfill-intl-normalizer" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-intl-normalizer-bc45c394692b948b4d383a08d7753968bed9a83d";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-intl-normalizer/zipball/bc45c394692b948b4d383a08d7753968bed9a83d";
          sha256 = "1zq1kklvjl4zj2v6yjzg7rv6ibvhxfymgi2xb0m5cw9r6i63rinw";
        };
      };
    };
    "symfony/polyfill-mbstring" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-mbstring-9773676c8a1bb1f8d4340a62efe641cf76eda7ec";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-mbstring/zipball/9773676c8a1bb1f8d4340a62efe641cf76eda7ec";
          sha256 = "1jpa4wwjfdkkhdpisviy1p4fhik00cldj5msipwl0izkia1d2qgf";
        };
      };
    };
    "symfony/polyfill-php72" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-php72-861391a8da9a04cbad2d232ddd9e4893220d6e25";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-php72/zipball/861391a8da9a04cbad2d232ddd9e4893220d6e25";
          sha256 = "0b4nw7x6c7jjn9bvkpqjnpszx647lncyswpk2iz57c1xl5dqywvh";
        };
      };
    };
    "symfony/polyfill-php80" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-php80-87b68208d5c1188808dd7839ee1e6c8ec3b02f1b";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-php80/zipball/87b68208d5c1188808dd7839ee1e6c8ec3b02f1b";
          sha256 = "1pn6dzj8b3h8851w3y6mj5qrwklwky5w71v4m455553qlga5cfr7";
        };
      };
    };
    "symfony/polyfill-php83" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-php83-86fcae159633351e5fd145d1c47de6c528f8caff";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-php83/zipball/86fcae159633351e5fd145d1c47de6c528f8caff";
          sha256 = "0n81fmn058rn7hr70qdwpsnam57pp27avs3h8xcfnq8d3hci5gr4";
        };
      };
    };
    "symfony/polyfill-uuid" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-uuid-3abdd21b0ceaa3000ee950097bc3cf9efc137853";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/polyfill-uuid/zipball/3abdd21b0ceaa3000ee950097bc3cf9efc137853";
          sha256 = "15g5ng1bcca4nqxjrcjabc1v679zl6xwm1wwfngvww1hvrbgd98d";
        };
      };
    };
    "symfony/process" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-process-0e7727191c3b71ebec6d529fa0e50a01ca5679e9";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/process/zipball/0e7727191c3b71ebec6d529fa0e50a01ca5679e9";
          sha256 = "0qn76c70i5v3lv1q9v0xjqrix0nw7bkny425gig6wzninvkzyah8";
        };
      };
    };
    "symfony/psr-http-message-bridge" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-psr-http-message-bridge-d9fadaf9541d7c01c307e48905d7ce1dbee6bf38";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/psr-http-message-bridge/zipball/d9fadaf9541d7c01c307e48905d7ce1dbee6bf38";
          sha256 = "1sgjik00bd20268m9rb64z6cp2ryw0m2yr655abhnl2flhlwb1i7";
        };
      };
    };
    "symfony/routing" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-routing-ba6bf07d43289c6a4b4591ddb75bc3bc5f069c19";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/routing/zipball/ba6bf07d43289c6a4b4591ddb75bc3bc5f069c19";
          sha256 = "0zs10g1x62bp8gskwal2pa7v8di8xzbviqj2rkyr6y0n3xcz5nj7";
        };
      };
    };
    "symfony/service-contracts" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-service-contracts-fe07cbc8d837f60caf7018068e350cc5163681a0";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/service-contracts/zipball/fe07cbc8d837f60caf7018068e350cc5163681a0";
          sha256 = "0gyhi5xhchvhxnbnzjr9xjmbgvwz6s8cvjslbb1603cwgdy7npxh";
        };
      };
    };
    "symfony/string" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-string-f5832521b998b0bec40bee688ad5de98d4cf111b";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/string/zipball/f5832521b998b0bec40bee688ad5de98d4cf111b";
          sha256 = "1fmh407h85a1g9cyizd057ypxm0m582q3vsr6jkfaidjxj839zfa";
        };
      };
    };
    "symfony/translation" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-translation-5b75e872f7d135d7abb4613809fadc8d9f3d30a0";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/translation/zipball/5b75e872f7d135d7abb4613809fadc8d9f3d30a0";
          sha256 = "0mln7q1mpaq6mdmc6gdgcawsvwzihzh8imzrl32aknsp3hancw7r";
        };
      };
    };
    "symfony/translation-contracts" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-translation-contracts-06450585bf65e978026bda220cdebca3f867fde7";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/translation-contracts/zipball/06450585bf65e978026bda220cdebca3f867fde7";
          sha256 = "1gd7ib8sdvi0byvc497i2d00nn8b0f9xsjgiyfwk0xzidq1dqwpy";
        };
      };
    };
    "symfony/uid" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-uid-87cedaf3fabd7b733859d4d77aa4ca598259054b";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/uid/zipball/87cedaf3fabd7b733859d4d77aa4ca598259054b";
          sha256 = "1bm0c5nsfvgn8r2dcn71b19s1lpi8ldpcv5qiaxm534k7pz1fqj2";
        };
      };
    };
    "symfony/var-dumper" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-var-dumper-e03ad7c1535e623edbb94c22cc42353e488c6670";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/var-dumper/zipball/e03ad7c1535e623edbb94c22cc42353e488c6670";
          sha256 = "1mbq44qi8mlj8w0yvrjcgbsckaq7z69nzy5jzxrdnbc81j71f1rw";
        };
      };
    };
    "symfony/var-exporter" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-var-exporter-dfb0acb6803eb714f05d97dd4c5abe6d5fa9fe41";
        src = fetchurl {
          url = "https://api.github.com/repos/symfony/var-exporter/zipball/dfb0acb6803eb714f05d97dd4c5abe6d5fa9fe41";
          sha256 = "012k9m8hz5j7dp0q47k3c82m804j53nzkv70vr1w6ddmm4xmn9lr";
        };
      };
    };
    "tijsverkoyen/css-to-inline-styles" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "tijsverkoyen-css-to-inline-styles-83ee6f38df0a63106a9e4536e3060458b74ccedb";
        src = fetchurl {
          url = "https://api.github.com/repos/tijsverkoyen/CssToInlineStyles/zipball/83ee6f38df0a63106a9e4536e3060458b74ccedb";
          sha256 = "1ahj49c7qz6m3y65jd18cz2c8cg6zqhkmnsrqrw1bf3s8ly9a9bp";
        };
      };
    };
    "twig/twig" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "twig-twig-9d15f0ac07f44dc4217883ec6ae02fd555c6f71d";
        src = fetchurl {
          url = "https://api.github.com/repos/twigphp/Twig/zipball/9d15f0ac07f44dc4217883ec6ae02fd555c6f71d";
          sha256 = "1vx01zb8ggccff3yvv3ng02l6k9w2yc38a07wd0n19qam6lis29z";
        };
      };
    };
    "vlucas/phpdotenv" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "vlucas-phpdotenv-2cf9fb6054c2bb1d59d1f3817706ecdb9d2934c4";
        src = fetchurl {
          url = "https://api.github.com/repos/vlucas/phpdotenv/zipball/2cf9fb6054c2bb1d59d1f3817706ecdb9d2934c4";
          sha256 = "0zb5gm5i6rnmm9zc4mi3wkkhpgciaa76w8jyxnw914xwq1xqzivx";
        };
      };
    };
    "voku/portable-ascii" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "voku-portable-ascii-b56450eed252f6801410d810c8e1727224ae0743";
        src = fetchurl {
          url = "https://api.github.com/repos/voku/portable-ascii/zipball/b56450eed252f6801410d810c8e1727224ae0743";
          sha256 = "0gwlv1hr6ycrf8ik1pnvlwaac8cpm8sa1nf4d49s8rp4k2y5anyl";
        };
      };
    };
    "webmozart/assert" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "webmozart-assert-11cb2199493b2f8a3b53e7f19068fc6aac760991";
        src = fetchurl {
          url = "https://api.github.com/repos/webmozarts/assert/zipball/11cb2199493b2f8a3b53e7f19068fc6aac760991";
          sha256 = "18qiza1ynwxpi6731jx1w5qsgw98prld1lgvfk54z92b1nc7psix";
        };
      };
    };
  };
  devPackages = {
    "barryvdh/laravel-debugbar" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "barryvdh-laravel-debugbar-aac8f08b73af8c5d2ab6595c8823ddb26d1453f1";
        src = fetchurl {
          url = "https://api.github.com/repos/barryvdh/laravel-debugbar/zipball/aac8f08b73af8c5d2ab6595c8823ddb26d1453f1";
          sha256 = "096inw71jvhg8fkhzqd95il515j3f5vyz215xyqz181pkpbadj75";
        };
      };
    };
    "barryvdh/laravel-ide-helper" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "barryvdh-laravel-ide-helper-bc1d67f01ce8c77e3f97d48ba51fa1d81874f622";
        src = fetchurl {
          url = "https://api.github.com/repos/barryvdh/laravel-ide-helper/zipball/bc1d67f01ce8c77e3f97d48ba51fa1d81874f622";
          sha256 = "1rf3lcxddfy7g26h3c0gnml113z1vz4r8waq33kx5z9dbmhf8qpx";
        };
      };
    };
    "barryvdh/reflection-docblock" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "barryvdh-reflection-docblock-e6811e927f0ecc37cc4deaa6627033150343e597";
        src = fetchurl {
          url = "https://api.github.com/repos/barryvdh/ReflectionDocBlock/zipball/e6811e927f0ecc37cc4deaa6627033150343e597";
          sha256 = "08gsiwza5n66mkpc07lpc0w505rrz0rv0dp9jiwk3ain0jl54yfw";
        };
      };
    };
    "composer/class-map-generator" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "composer-class-map-generator-8286a62d243312ed99b3eee20d5005c961adb311";
        src = fetchurl {
          url = "https://api.github.com/repos/composer/class-map-generator/zipball/8286a62d243312ed99b3eee20d5005c961adb311";
          sha256 = "1393cqb13zim63jvkjfi6nkdkrjw8cj8wskq8lf2jnz9ab5n7sa4";
        };
      };
    };
    "composer/pcre" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "composer-pcre-5b16e25a5355f1f3afdfc2f954a0a80aec4826a8";
        src = fetchurl {
          url = "https://api.github.com/repos/composer/pcre/zipball/5b16e25a5355f1f3afdfc2f954a0a80aec4826a8";
          sha256 = "0wyvmmvjf3hw717v6j9xjwpx1f1mrjv6m552nd95pmznjfvcmkdi";
        };
      };
    };
    "doctrine/deprecations" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "doctrine-deprecations-dfbaa3c2d2e9a9df1118213f3b8b0c597bb99fab";
        src = fetchurl {
          url = "https://api.github.com/repos/doctrine/deprecations/zipball/dfbaa3c2d2e9a9df1118213f3b8b0c597bb99fab";
          sha256 = "1qydhnf94wgjlrgzydjcz31rr5f87pg3vlkkd0gynggw1ycgkkcg";
        };
      };
    };
    "ergebnis/phpstan-rules" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "ergebnis-phpstan-rules-2e9946491d39ea1eb043738309895e08f025a7a0";
        src = fetchurl {
          url = "https://api.github.com/repos/ergebnis/phpstan-rules/zipball/2e9946491d39ea1eb043738309895e08f025a7a0";
          sha256 = "0yp8rz66myzgk9nx9kphc3j7lz3n2lfbhr8j112hsw7dm4mp5aad";
        };
      };
    };
    "fakerphp/faker" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "fakerphp-faker-bfb4fe148adbf78eff521199619b93a52ae3554b";
        src = fetchurl {
          url = "https://api.github.com/repos/FakerPHP/Faker/zipball/bfb4fe148adbf78eff521199619b93a52ae3554b";
          sha256 = "0iv7a1r7n2js07dl9xvc9v3x3nvln4z7i6pmlgyvz1lj3czyfmqm";
        };
      };
    };
    "hamcrest/hamcrest-php" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "hamcrest-hamcrest-php-8c3d0a3f6af734494ad8f6fbbee0ba92422859f3";
        src = fetchurl {
          url = "https://api.github.com/repos/hamcrest/hamcrest-php/zipball/8c3d0a3f6af734494ad8f6fbbee0ba92422859f3";
          sha256 = "1ixmmpplaf1z36f34d9f1342qjbcizvi5ddkjdli6jgrbla6a6hr";
        };
      };
    };
    "larastan/larastan" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "larastan-larastan-a79b46b96060504b400890674b83f66aa7f5db6d";
        src = fetchurl {
          url = "https://api.github.com/repos/larastan/larastan/zipball/a79b46b96060504b400890674b83f66aa7f5db6d";
          sha256 = "0ammqzs49fir4gpjxzaklgrw7vf6fnwychqppjddgl2cnlkrs0db";
        };
      };
    };
    "maximebf/debugbar" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "maximebf-debugbar-0b407703b08ea0cf6ebc61e267cc96ff7000911b";
        src = fetchurl {
          url = "https://api.github.com/repos/maximebf/php-debugbar/zipball/0b407703b08ea0cf6ebc61e267cc96ff7000911b";
          sha256 = "06144n5sd904zdl23gpnyzm07cgbsszh27wwmh81kidj16m1z9j4";
        };
      };
    };
    "mockery/mockery" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "mockery-mockery-81a161d0b135df89951abd52296adf97deb0723d";
        src = fetchurl {
          url = "https://api.github.com/repos/mockery/mockery/zipball/81a161d0b135df89951abd52296adf97deb0723d";
          sha256 = "0kcf7v4ca52pfcgfqg1fp37dly4sx0fv62m7gy6jng9p4nra3xwg";
        };
      };
    };
    "myclabs/deep-copy" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "myclabs-deep-copy-7284c22080590fb39f2ffa3e9057f10a4ddd0e0c";
        src = fetchurl {
          url = "https://api.github.com/repos/myclabs/DeepCopy/zipball/7284c22080590fb39f2ffa3e9057f10a4ddd0e0c";
          sha256 = "16k44y94bcr439bsxm5158xvmlyraph2c6n17qa5y29b04jqdw5j";
        };
      };
    };
    "nikic/php-parser" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "nikic-php-parser-139676794dc1e9231bf7bcd123cfc0c99182cb13";
        src = fetchurl {
          url = "https://api.github.com/repos/nikic/PHP-Parser/zipball/139676794dc1e9231bf7bcd123cfc0c99182cb13";
          sha256 = "1z4bvxvxs09099i3khiydmzy8lqjvk8kdani2qipmkq9vzf9pq56";
        };
      };
    };
    "phar-io/manifest" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phar-io-manifest-54750ef60c58e43759730615a392c31c80e23176";
        src = fetchurl {
          url = "https://api.github.com/repos/phar-io/manifest/zipball/54750ef60c58e43759730615a392c31c80e23176";
          sha256 = "0xas0i7jd6w4hknfmbwdswpzngblm3d884hy3rba0q2cs928ndml";
        };
      };
    };
    "phar-io/version" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phar-io-version-4f7fd7836c6f332bb2933569e566a0d6c4cbed74";
        src = fetchurl {
          url = "https://api.github.com/repos/phar-io/version/zipball/4f7fd7836c6f332bb2933569e566a0d6c4cbed74";
          sha256 = "0mdbzh1y0m2vvpf54vw7ckcbcf1yfhivwxgc9j9rbb7yifmlyvsg";
        };
      };
    };
    "phpdocumentor/reflection-common" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpdocumentor-reflection-common-1d01c49d4ed62f25aa84a747ad35d5a16924662b";
        src = fetchurl {
          url = "https://api.github.com/repos/phpDocumentor/ReflectionCommon/zipball/1d01c49d4ed62f25aa84a747ad35d5a16924662b";
          sha256 = "1wx720a17i24471jf8z499dnkijzb4b8xra11kvw9g9hhzfadz1r";
        };
      };
    };
    "phpdocumentor/type-resolver" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpdocumentor-type-resolver-153ae662783729388a584b4361f2545e4d841e3c";
        src = fetchurl {
          url = "https://api.github.com/repos/phpDocumentor/TypeResolver/zipball/153ae662783729388a584b4361f2545e4d841e3c";
          sha256 = "1m934q8ydb4kr1akcask1d8db4ap560zmk534phz0s9862fj5cqi";
        };
      };
    };
    "phpmyadmin/sql-parser" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpmyadmin-sql-parser-011fa18a4e55591fac6545a821921dd1d61c6984";
        src = fetchurl {
          url = "https://api.github.com/repos/phpmyadmin/sql-parser/zipball/011fa18a4e55591fac6545a821921dd1d61c6984";
          sha256 = "0iib3w8f0v3b13c38sfdfmxl97i82i9hdirz2bkvwbakwl6lrkfv";
        };
      };
    };
    "phpstan/extension-installer" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpstan-extension-installer-f45734bfb9984c6c56c4486b71230355f066a58a";
        src = fetchurl {
          url = "https://api.github.com/repos/phpstan/extension-installer/zipball/f45734bfb9984c6c56c4486b71230355f066a58a";
          sha256 = "1b9np3csi5bai9b03xfvsmkgkqjqha3iny5k2hv8348r2vha9lbh";
        };
      };
    };
    "phpstan/phpdoc-parser" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpstan-phpdoc-parser-86e4d5a4b036f8f0be1464522f4c6b584c452757";
        src = fetchurl {
          url = "https://api.github.com/repos/phpstan/phpdoc-parser/zipball/86e4d5a4b036f8f0be1464522f4c6b584c452757";
          sha256 = "192jhcqg7s5c6nil8bxsqq85ws2fyckj9k7n1zb0d5zs4sqkahl6";
        };
      };
    };
    "phpstan/phpstan" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpstan-phpstan-94779c987e4ebd620025d9e5fdd23323903950bd";
        src = fetchurl {
          url = "https://api.github.com/repos/phpstan/phpstan/zipball/94779c987e4ebd620025d9e5fdd23323903950bd";
          sha256 = "12yld4lyg2rnw50ls2by5agi9ah04wmp6ylhia7xaz660146dgi7";
        };
      };
    };
    "phpstan/phpstan-deprecation-rules" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpstan-phpstan-deprecation-rules-089d8a8258ed0aeefdc7b68b6c3d25572ebfdbaa";
        src = fetchurl {
          url = "https://api.github.com/repos/phpstan/phpstan-deprecation-rules/zipball/089d8a8258ed0aeefdc7b68b6c3d25572ebfdbaa";
          sha256 = "18xa0imp7xiwaqir627sy2zf8q378cgdi3j6b7n93idbg2ixbp4p";
        };
      };
    };
    "phpstan/phpstan-strict-rules" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpstan-phpstan-strict-rules-7a50e9662ee9f3942e4aaaf3d603653f60282542";
        src = fetchurl {
          url = "https://api.github.com/repos/phpstan/phpstan-strict-rules/zipball/7a50e9662ee9f3942e4aaaf3d603653f60282542";
          sha256 = "05xn7jmw3yz3s2wr4svnjfbvqz834frr0w61dzdvf341q0a3p7r6";
        };
      };
    };
    "phpunit/php-code-coverage" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpunit-php-code-coverage-e3f51450ebffe8e0efdf7346ae966a656f7d5e5b";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/php-code-coverage/zipball/e3f51450ebffe8e0efdf7346ae966a656f7d5e5b";
          sha256 = "0k05ml1kvg17ghmlqxpb5g92lv5srwd5das6cjkvifbhbv3w5sxv";
        };
      };
    };
    "phpunit/php-file-iterator" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpunit-php-file-iterator-a95037b6d9e608ba092da1b23931e537cadc3c3c";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/php-file-iterator/zipball/a95037b6d9e608ba092da1b23931e537cadc3c3c";
          sha256 = "1cxdrmvffx6zicjq41hs93jzwzr536vpk9b9vx6cpbyz08v3bbgj";
        };
      };
    };
    "phpunit/php-invoker" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpunit-php-invoker-f5e568ba02fa5ba0ddd0f618391d5a9ea50b06d7";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/php-invoker/zipball/f5e568ba02fa5ba0ddd0f618391d5a9ea50b06d7";
          sha256 = "16hdigfcwzynbnrs29ha7l1pjr81rf2510jx3z3nhmgz9fys7jsl";
        };
      };
    };
    "phpunit/php-text-template" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpunit-php-text-template-0c7b06ff49e3d5072f057eb1fa59258bf287a748";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/php-text-template/zipball/0c7b06ff49e3d5072f057eb1fa59258bf287a748";
          sha256 = "083gkd6rp4zdyh1y8cmplrpfcfa0brn4vmgbcillgsjxxs25pkcs";
        };
      };
    };
    "phpunit/php-timer" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpunit-php-timer-e2a2d67966e740530f4a3343fe2e030ffdc1161d";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/php-timer/zipball/e2a2d67966e740530f4a3343fe2e030ffdc1161d";
          sha256 = "02skpc6b31lgqnjxsh8x3b4mvr6pz8zp5672dllgfknf70byzy1f";
        };
      };
    };
    "phpunit/phpunit" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpunit-phpunit-18f8d4a5f52b61fdd9370aaae3167daa0eeb69cd";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/phpunit/zipball/18f8d4a5f52b61fdd9370aaae3167daa0eeb69cd";
          sha256 = "071vzpq8zkqpw0p4dlysdi99jdcvd4p5fvynbiqgzv8qxpjdmz7g";
        };
      };
    };
    "sebastian/cli-parser" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-cli-parser-c34583b87e7b7a8055bf6c450c2c77ce32a24084";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/cli-parser/zipball/c34583b87e7b7a8055bf6c450c2c77ce32a24084";
          sha256 = "0wz2mddfyk2pq8nxl6vji4rba671z6m0xgd80jirik717wcjl9jf";
        };
      };
    };
    "sebastian/code-unit" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-code-unit-a81fee9eef0b7a76af11d121767abc44c104e503";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/code-unit/zipball/a81fee9eef0b7a76af11d121767abc44c104e503";
          sha256 = "0k480x92974k4w2nvaf19xz3brwmjvh84h4wya4xp8vn5a6p3gfg";
        };
      };
    };
    "sebastian/code-unit-reverse-lookup" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-code-unit-reverse-lookup-5e3a687f7d8ae33fb362c5c0743794bbb2420a1d";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/code-unit-reverse-lookup/zipball/5e3a687f7d8ae33fb362c5c0743794bbb2420a1d";
          sha256 = "03x25cyiivl8mf4bgk22c2ivdkh3q7sh59nhivjag2rpnylsj8gb";
        };
      };
    };
    "sebastian/comparator" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-comparator-2db5010a484d53ebf536087a70b4a5423c102372";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/comparator/zipball/2db5010a484d53ebf536087a70b4a5423c102372";
          sha256 = "1isk6l8gxk2pk9vxzblw429pny6c6jpyik81svm289lbscy151kc";
        };
      };
    };
    "sebastian/complexity" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-complexity-68ff824baeae169ec9f2137158ee529584553799";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/complexity/zipball/68ff824baeae169ec9f2137158ee529584553799";
          sha256 = "0cpbnmvia2zvnny174gfg8q2i6r3gmhhhh8qlzgasck0zfrv4y5h";
        };
      };
    };
    "sebastian/diff" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-diff-c41e007b4b62af48218231d6c2275e4c9b975b2e";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/diff/zipball/c41e007b4b62af48218231d6c2275e4c9b975b2e";
          sha256 = "0aisnxicr3wbr51ycbcyd32mvh7hw28w3yq2jc0c4qig1xbdbwcc";
        };
      };
    };
    "sebastian/environment" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-environment-8074dbcd93529b357029f5cc5058fd3e43666984";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/environment/zipball/8074dbcd93529b357029f5cc5058fd3e43666984";
          sha256 = "07qzbivf10qs2c6vvyl83szk5iig690cign4wcf182lk6qnfgsmc";
        };
      };
    };
    "sebastian/exporter" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-exporter-955288482d97c19a372d3f31006ab3f37da47adf";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/exporter/zipball/955288482d97c19a372d3f31006ab3f37da47adf";
          sha256 = "0j75qiiacnlrksna7x9x8vazg769jr4wib1c7srwgmr0q6jdfsbd";
        };
      };
    };
    "sebastian/global-state" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-global-state-987bafff24ecc4c9ac418cab1145b96dd6e9cbd9";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/global-state/zipball/987bafff24ecc4c9ac418cab1145b96dd6e9cbd9";
          sha256 = "116vs035nz4qacjfm9zh729ai5f29fvlqr0jpb3majaxr9gjk54g";
        };
      };
    };
    "sebastian/lines-of-code" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-lines-of-code-856e7f6a75a84e339195d48c556f23be2ebf75d0";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/lines-of-code/zipball/856e7f6a75a84e339195d48c556f23be2ebf75d0";
          sha256 = "01jlnxir7il82w1qf2nz9476mv11vhfp97sms93fy8pyk40m3j8k";
        };
      };
    };
    "sebastian/object-enumerator" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-object-enumerator-202d0e344a580d7f7d04b3fafce6933e59dae906";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/object-enumerator/zipball/202d0e344a580d7f7d04b3fafce6933e59dae906";
          sha256 = "1gqlp8dkjgm9zsbklk7rwc3d9nf3mqws6l445vls2q2h6a9j37w1";
        };
      };
    };
    "sebastian/object-reflector" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-object-reflector-24ed13d98130f0e7122df55d06c5c4942a577957";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/object-reflector/zipball/24ed13d98130f0e7122df55d06c5c4942a577957";
          sha256 = "0imfh72b7yjgjnyfh2zrjsfqznz0c6hcsvmp4igmn4cb3w3vpbpv";
        };
      };
    };
    "sebastian/recursion-context" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-recursion-context-05909fb5bc7df4c52992396d0116aed689f93712";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/recursion-context/zipball/05909fb5bc7df4c52992396d0116aed689f93712";
          sha256 = "1dr3wsyx3s5kanlg4s9qgn35wbjjrmhycp31n3azqskalp4whzy5";
        };
      };
    };
    "sebastian/type" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-type-462699a16464c3944eefc02ebdd77882bd3925bf";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/type/zipball/462699a16464c3944eefc02ebdd77882bd3925bf";
          sha256 = "0g2im923glz133bbkz3r12i2n1zpk7d7198znzcms6cs99v6b6mc";
        };
      };
    };
    "sebastian/version" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sebastian-version-c51fa83a5d8f43f1402e3f32a005e6262244ef17";
        src = fetchurl {
          url = "https://api.github.com/repos/sebastianbergmann/version/zipball/c51fa83a5d8f43f1402e3f32a005e6262244ef17";
          sha256 = "14cirib9q5r4nn5cvyv3hba07qvpw4dwdnsiz67c3rf4ghjwgfym";
        };
      };
    };
    "thecodingmachine/phpstan-strict-rules" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "thecodingmachine-phpstan-strict-rules-2ba8fa8b328c45f3b149c05def5bf96793c594b6";
        src = fetchurl {
          url = "https://api.github.com/repos/thecodingmachine/phpstan-strict-rules/zipball/2ba8fa8b328c45f3b149c05def5bf96793c594b6";
          sha256 = "1irxnsw1phykm5wz281dmwyqwc5l1drzlwvn46vp2y6bipl73jsa";
        };
      };
    };
    "theseer/tokenizer" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "theseer-tokenizer-737eda637ed5e28c3413cb1ebe8bb52cbf1ca7a2";
        src = fetchurl {
          url = "https://api.github.com/repos/theseer/tokenizer/zipball/737eda637ed5e28c3413cb1ebe8bb52cbf1ca7a2";
          sha256 = "1pi1wlzmyzla2wli0h3kqf8vhddhqra2bkp9rg81b38pbh791w34";
        };
      };
    };
  };
in
  composerEnv.buildPackage {
    inherit packages devPackages noDev;
    name = "firefly-iii";
    src = composerEnv.filterSrc ./.;
    executable = false;
    symlinkDependencies = false;
    meta = {
      homepage = "https://github.com/firefly-iii/firefly-iii";
      license = "AGPL-3.0-or-later";
    };
  }
