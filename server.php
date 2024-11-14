<?php


Route::get('push_to_update', function (Request $request) {
    $now = Carbon::now();
    $timestamp = $now->timestamp; // 獲取當前時間的秒數
    $nanoseconds = $now->micro * 1000; // 獲取當前時間的納秒數

    $pushToken = '';
    $bundleId = 'org.reactjs.native.example.OrderDemo';

    $privateKey = file_get_contents(storage_path() . '/p8');
    $teamId = '';
    $keyId = '';

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
            'event' => 'update',
            'relevance-score' => 100.0,
            'stale-date' => $timestamp + 60 * 60 * 8,
            'content-state' => [
                'memberId' => '',
                'memberAccessToken' => '',
                'parkedAt' => null,
                'chargedAt' => null,
                'estimatedFee' => null,
                'last4CardNumber' => null,
                'carPlate' => null,
                'paymentMethod' => null,
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

    $pushToken = '';
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