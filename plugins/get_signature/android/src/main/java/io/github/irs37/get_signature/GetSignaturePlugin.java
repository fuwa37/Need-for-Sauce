package io.github.irs37.get_signature;

import androidx.annotation.NonNull;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.Signature;
import android.content.pm.SigningInfo;
import android.os.Build;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * GetSignaturePlugin
 */
public class GetSignaturePlugin implements FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    private Context context;

    public static void registerWith(Registrar registrar) {
        final GetSignaturePlugin instance = new GetSignaturePlugin();
        instance.onAttachedToEngine(registrar.context(), registrar.messenger());
    }

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        onAttachedToEngine(
                binding.getApplicationContext(), binding.getFlutterEngine().getDartExecutor());
    }

    private void onAttachedToEngine(Context applicationContext, BinaryMessenger messenger) {
        this.context = applicationContext;
        channel = new MethodChannel(messenger, "get_signature");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else if (call.method.equals("getSignature")) {
            try {
                SigningInfo sig;
                Signature[] sigs;
                String sign;

                PackageManager pm = context.getPackageManager();
                PackageInfo info = pm.getPackageInfo(context.getPackageName(), 0);
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    sig = pm.getPackageInfo(context.getPackageName(), PackageManager.GET_SIGNING_CERTIFICATES).signingInfo;
                    sign = String.valueOf(sig.getApkContentsSigners()[0].hashCode());
                } else {
                    sigs = pm.getPackageInfo(context.getPackageName(), PackageManager.GET_SIGNATURES).signatures;
                    sign = String.valueOf(sigs[0].hashCode());
                }

                result.success(sign);
            } catch (PackageManager.NameNotFoundException ex) {
                result.error("Name not found", ex.getMessage(), null);
            }
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}
