/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import React from 'react';
import {
  SafeAreaView,
  ScrollView,
  StatusBar,
  StyleSheet,
  View,
  Button,
  NativeModules,
  TextInput,
  TouchableOpacity,
  Text,
} from 'react-native';

const {OrderWidgetModule} = NativeModules;
function App(): React.JSX.Element {
  const [amount, setAmount] = React.useState(299);

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar />
      <ScrollView contentInsetAdjustmentBehavior="automatic">
        <View style={styles.row}>
          <TextInput
            placeholder="金額"
            value={amount.toString()}
            onChangeText={text => setAmount(parseInt(text, 10))}
          />
          <View style={styles.button}>
            <TouchableOpacity
              onPress={() => {
                console.log('startLiveActivity');
                OrderWidgetModule.startLiveActivity({
                  accessToken:
                    'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhZG1pbiI6dHJ1ZSwiZXhwIjoxNjg3NDk4NTI2LCJwaG9uZSI6IjA5ODczNDU2NzIiLCJ1dWlkIjoiZmM1MmUwZGYtOGVlYS00MzRjLWFmNmMtNGQ2MjAyZTgyMTk5In0.oqow629xA4mm3b2q7yAqjHY0-8-Izu185OWfvhuNiDg',
                  estimatedFee: 299,
                  carPlate: 'REN-8765', // 可選
                  last4CardNumber: '1234', // 可選
                  paymentMethod: 'card', // 可選
                  parkedAt: new Date().getTime(),
                  chargedAt: new Date().getTime(),
                });
              }}>
              <Text>啟動 Live Activity</Text>
            </TouchableOpacity>
          </View>

          <View style={styles.button}>
            <TouchableOpacity
              onPress={() => {
                console.log('stopLiveActivity');
                OrderWidgetModule.stopLiveActivity();
              }}>
              <Text>停止 Live Activity</Text>
            </TouchableOpacity>
          </View>

          <View style={styles.button}>
            <TouchableOpacity
              onPress={() => {
                console.log('updateState');
                OrderWidgetModule.updateState({
                  estimatedFee: amount,
                  carPlate: 'ABC-123',
                  paymentMethod: '',
                  last4CardNumber: null,
                });
              }}>
              <Text>更新 ContentState</Text>
            </TouchableOpacity>
          </View>

          <View style={styles.button}>
            <TouchableOpacity
              onPress={() => {
                console.log('syncPushToStartToken');
                OrderWidgetModule.syncPushToStartToken({
                  accessToken:
                    'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhZG1pbiI6dHJ1ZSwiZXhwIjoxNjg3NDk4NTI2LCJwaG9uZSI6IjA5ODczNDU2NzIiLCJ1dWlkIjoiZmM1MmUwZGYtOGVlYS00MzRjLWFmNmMtNGQ2MjAyZTgyMTk5In0.oqow629xA4mm3b2q7yAqjHY0-8-Izu185OWfvhuNiDg',
                });
              }}>
              <Text>取得 Push to Start Token</Text>
            </TouchableOpacity>
          </View>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
  },
  row: {
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
  },
  button: {
    width: 200,
    height: 50,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 1,
    borderColor: 'gray',
    borderRadius: 10,
    marginTop: 10,
    marginBottom: 10,
  },
});

export default App;
