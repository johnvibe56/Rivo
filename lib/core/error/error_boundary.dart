import 'package:flutter/material.dart';

/// A widget that catches and displays errors that occur in its child widget tree.
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stackTrace)? fallback;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  ErrorBoundaryState createState() => ErrorBoundaryState();
}

/// The state for [ErrorBoundary].
class ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void reassemble() {
    super.reassemble();
    // Reset error state when hot reloading
    if (_error != null) {
      setState(() {
        _error = null;
        _stackTrace = null;
      });
    }
  }

  void _handleError(Object error, StackTrace stackTrace) {
    setState(() {
      _error = error;
      _stackTrace = stackTrace;
    });
    
    // Log the error for debugging
    debugPrint('ErrorBoundary caught error: $error\n$stackTrace');
  }

  Widget _buildErrorUI(BuildContext context) {
    if (widget.fallback != null) {
      return widget.fallback!(_error!, _stackTrace);
    }
    
    // Default error UI
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 24),
              Text(
                'Oops! Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Error Details:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error.toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  setState(() {
                    _error = null;
                    _stackTrace = null;
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _buildErrorUI(context);
    }
    
    // Use a Builder to get a new context that's a child of this widget
    return Builder(
      builder: (BuildContext context) {
        // Set up an error handler for the widget tree below
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          _handleError(errorDetails.exception, errorDetails.stack!);
          return _buildErrorUI(context);
        };
        
        // Return the child widget tree
        return widget.child;
      },
    );
  }
}
