// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poster_request.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PosterRequestAdapter extends TypeAdapter<PosterRequest> {
  @override
  final int typeId = 0;

  @override
  PosterRequest read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PosterRequest(
      uniqueId: fields[0] as String,
      posterNumber: fields[1] as String,
      timestampSent: fields[2] as DateTime,
      timestampPulled: fields[3] as DateTime?,
      status: fields[4] as RequestStatus,
      isSynced: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PosterRequest obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.uniqueId)
      ..writeByte(1)
      ..write(obj.posterNumber)
      ..writeByte(2)
      ..write(obj.timestampSent)
      ..writeByte(3)
      ..write(obj.timestampPulled)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PosterRequestAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RequestStatusAdapter extends TypeAdapter<RequestStatus> {
  @override
  final int typeId = 1;

  @override
  RequestStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RequestStatus.sent;
      case 1:
        return RequestStatus.pending;
      case 2:
        return RequestStatus.fulfilled;
      default:
        return RequestStatus.sent;
    }
  }

  @override
  void write(BinaryWriter writer, RequestStatus obj) {
    switch (obj) {
      case RequestStatus.sent:
        writer.writeByte(0);
        break;
      case RequestStatus.pending:
        writer.writeByte(1);
        break;
      case RequestStatus.fulfilled:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RequestStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
