<?php


Route::get('push_to_update', function (Request $request) {
    $now = Carbon::now();
    $timestamp = $now->timestamp; // 獲取當前時間的秒數
    $nanoseconds = $now->micro * 1000; // 獲取當前時間的納秒數

    $pushToken = '806ef33bc77e4598d9b4494f6e67e65fd8190036bb3d8481b45b5c1fa1da48bd6d939285d3962df53edafc53e49a396d0dfc76954c2fb1c8f222ed908ed9eb1357cca92cd2d44b64effb70cb419b46b3ccb639ddee0ead5de1d7de01630122560a7c20bbce0eaee3ff289579fb155115f23f0d451487195f15416f529dd34c67';
    $bundleId = 'city.uspace.LiveChange';

    $privateKey = file_get_contents(storage_path() . '/uspace_apple_auth_key.p8');
    $teamId = '3A6A49P89Q';
    $keyId = '9PL37T34S6';

    // $header = [
    //     'alg' => 'ES256',
    //     'kid' => $keyId
    // ];
    $payload = [
        'iss' => $teamId,
        'iat' => $timestamp
    ];
    $accessToken = JWT::encode($payload, $privateKey, 'ES256', $keyId);
    // $accessToken = JWT::encode($payload, $privateKey, 'ES256', $keyId, $header);

    $client = new Client([
        'base_uri' => 'https://api.sandbox.push.apple.com',
        'verify' => true,
        'version' => 2.0,
        // 'curl' => [
        //     CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_2_0,
        //     CURLOPT_SSL_VERIFYPEER => true,
        //     CURLOPT_SSLVERSION => CURL_SSLVERSION_TLSv1_2
        // ]
    ]);

    $headers = [
        'authorization' => "bearer {$accessToken}",
        'apns-push-type' => 'liveactivity',
        'apns-topic' =>
            "{$bundleId}.push-type.liveactivity",
        'Content-Type' => 'application/json'
    ];

    $body = [
        'aps' => [
            'timestamp' => $timestamp,
            'event' => 'update',
            'relevance-score' => 100.0,
            'stale-date' => $timestamp + 60 * 60 * 8,
            'content-state' => [
                'id' => 'C2D85165-7A53-44FD-A072-AE90421A87EE',
                'lastUpdatedOptionId' => 'DF57EA61-A2EC-4600-8D9A-E91F2CF2E110',
                'name' => 'Best Mobile',
                'option0' => [
                    'id' => 'DF57EA61-A2EC-4600-8D9A-E91F2CF2E110',
                    'name' => 'iOS',
                    'count' => 9,
                ],
                'option1' => [
                    'id' => '167969C4-4D9E-46BD-8C0E-00ED4708E7AA',
                    'name' => 'Android',
                    'count' => 3,
                ],
                'totalCount' => 12,
                'createdAt' => null,
                'updatedAt' => [
                    'seconds' => $timestamp,
                    'nanoseconds' => $nanoseconds
                ]
            ]
        ]
    ];

    try {
        $response = $client->request('POST', "/3/device/{$pushToken}", [
            'headers' => $headers,
            'json' => $body,
            'http_errors' => false
        ]);
        $statusCode = $response->getStatusCode();
        $responseBody = $response->getBody()->getContents();
        dd($statusCode, $responseBody);
    } catch (\Exception $e) {
        dd($e);
    }
});

Route::get('push_to_stop', function (Request $request) {
    $now = Carbon::now();
    $timestamp = $now->timestamp;
    $nanoseconds = $now->micro * 1000;

    $pushToken = '803b2e522d57da32b3ba5fd227617404927da39069f0e401327d1774fadfc9a4a21d19aa5f0b574550c940c6a715b827a52bf688bbac728d3c2a231aab4196fb35193811a2f71f9bddb86ead8d264ab33a29e53a69816fcf8bc2585eaa1219fae9a8a77e50c113b6060bea6674ee8122922bab8725f9dee3eff687b8f7bdd958';
    $bundleId = 'org.reactjs.native.example.OrderDemo';

    $privateKey = file_get_contents(storage_path() . '/uspace_apple_auth_key.p8');
    $teamId = '3A6A49P89Q';
    $keyId = '9PL37T34S6';

    $payload = [
        'iss' => $teamId,
        'iat' => $timestamp
    ];
    $accessToken = JWT::encode($payload, $privateKey, 'ES256', $keyId);

    $client = new Client([
        'base_uri' => 'https://api.sandbox.push.apple.com',
        'verify' => true,
        'version' => 2.0,
    ]);

    $headers = [
        'authorization' => "bearer {$accessToken}",
        'apns-push-type' => 'liveactivity',
        'apns-topic' =>
            "{$bundleId}.push-type.liveactivity",
        'Content-Type' => 'application/json'
    ];

    $body = [
        'aps' => [
            'timestamp' => $timestamp,
            'event' => 'end',
            'content-state' => [
                'memberId' => '',
                'memberAccessToken' => '',
                'parkedAt' => null,
                'chargedAt' => null,
                'estimatedFee' => null,
                'last4CardNumber' => null,
                'carPlate' => null,
                'paymentMethod' => null,
            ],
            'dismissal-date' => $timestamp
        ]
    ];

    try {
        $response = $client->request('POST', "/3/device/{$pushToken}", [
            'headers' => $headers,
            'json' => $body,
            'http_errors' => false
        ]);
        $statusCode = $response->getStatusCode();
        $responseBody = $response->getBody()->getContents();
        dd($statusCode, $responseBody);
    } catch (\Exception $e) {
        dd($e);
    }
});